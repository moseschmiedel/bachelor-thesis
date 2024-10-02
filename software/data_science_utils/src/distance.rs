use linreg::linear_regression;
use plotters::backend::SVGBackend;
use plotters::chart::{ChartBuilder, LabelAreaPosition};
use plotters::drawing::IntoDrawingArea;
use plotters::element::{Cross, Drawable, EmptyElement, PathElement};
use plotters::series::{LineSeries, PointSeries};
use plotters::style::{Color, BLACK, RED, WHITE};
use polars::chunked_array::ops::SortMultipleOptions;
use polars::datatypes::AnyValue;
use polars::io::SerReader;
use polars::lazy::dsl::{col, lit};
use polars::prelude::{
    CategoricalOrdering, CsvReadOptions, DataFrame, DataType, Field, IntoLazy, NamedFrom,
    RevMapping, Schema, Series,
};
use polars_arrow::array::Utf8ViewArray;
use std::cmp;
use std::ops::{Deref, DerefMut, Div, Mul};
use std::sync::Arc;
use std::{ffi::OsString, fs, path::Path};

use crate::cli;
use crate::error::{self, Error};

pub fn run_evaluation(args: cli::DistanceArgs) -> error::Result<()> {
    let data_dir_path = Path::new(&args.data_dir);
    let enum_values = ["NULL", "Tag", "BeaconA", "BeaconB", "BeaconC"];
    let categories = Utf8ViewArray::from_slice(enum_values.iter().map(Some).collect::<Vec<_>>());
    let device_dtype = DataType::Enum(
        Some(RevMapping::build_local(categories).into()),
        CategoricalOrdering::Physical,
    );

    let schema = Schema::from_iter(
        vec![
            Field::new("device", device_dtype.clone()),
            Field::new("rssi_dbm", DataType::Int64),
            Field::new("distance_m", DataType::Float64),
        ]
        .into_iter(),
    );

    let mut data = DataFrame::empty_with_schema(&schema);

    for entry in fs::read_dir(data_dir_path)? {
        let entry = entry?;
        if let Some(file_ext) = entry.path().extension() {
            if file_ext.eq("csv") {
                let mut df = CsvReadOptions::default()
                    .with_schema(Some(Arc::new(Schema::from_iter(vec![
                        Field::new("timestamp", DataType::String),
                        Field::new("device", DataType::UInt64),
                        Field::new("rssi_dbm", DataType::Int64),
                    ]))))
                    .try_into_reader_with_file_path(Some(entry.path()))
                    .unwrap()
                    .finish()
                    .unwrap();
                let _ = df.drop_in_place("timestamp")?;

                let mut parsed_distance = 0.0;
                let file_name = entry
                    .path()
                    .file_stem()
                    .unwrap_or(&OsString::from(""))
                    .to_owned()
                    .into_string()
                    .map_err(Error::OsStringConversionError)?;
                if file_name.ends_with("cm") {
                    parsed_distance = file_name.trim_end_matches("cm").parse::<f64>()?;
                    parsed_distance /= 100.0;
                } else if file_name.ends_with("m") {
                    parsed_distance = file_name.trim_end_matches("m").parse::<f64>()?;
                }

                let mut distances = Series::new_empty("distance_m", &DataType::Float64);
                distances =
                    distances.extend_constant(AnyValue::Float64(parsed_distance), df.height())?;
                df.with_column(distances)?;
                df.replace(
                    "device",
                    Series::new(
                        "device",
                        df["device"]
                            .iter()
                            .map(|device_num| match device_num {
                                AnyValue::Int64(0) | AnyValue::UInt64(0) => "Tag",
                                AnyValue::Int64(1) | AnyValue::UInt64(1) => "BeaconA",
                                AnyValue::Int64(2) | AnyValue::UInt64(2) => "BeaconB",
                                AnyValue::Int64(3) | AnyValue::UInt64(3) => "BeaconC",
                                _ => "NULL",
                            })
                            .collect::<Vec<&str>>(),
                    )
                    .cast(&device_dtype)?,
                )?;

                data = data.vstack(&df)?;
            }
        }
    }

    data.align_chunks();

    let mut df_agg = data
        .lazy()
        .group_by(["distance_m"])
        .agg([col("rssi_dbm").mean()])
        .sort(
            ["distance_m"],
            SortMultipleOptions::new().with_order_descending(false),
        )
        .filter(col("distance_m").gt_eq(lit(args.min_distance.unwrap_or(0.0))))
        .collect()?;
    df_agg.set_column_names(&["distance_m", "avg_rssi_dbm"])?;

    let xs = df_agg["distance_m"]
        .iter()
        .map(|d| match d {
            AnyValue::Float64(value) => value.log10(),
            _ => 0.0,
        })
        .collect::<Vec<f64>>();
    let ys = df_agg["avg_rssi_dbm"]
        .f64()?
        .to_vec()
        .into_iter()
        .collect::<Option<Vec<f64>>>()
        .unwrap();

    let (slope, intercept) = linear_regression::<f64, f64, f64>(&xs, &ys)?;
    println!("Calculated RSSI model: RSSI = {slope} * log(distance) + {intercept}");

    df_agg = df_agg
        .lazy()
        .with_column(
            lit(10)
                .pow((col("avg_rssi_dbm") - lit(intercept)) / lit(slope))
                .alias("estimated_distance_m"),
        )
        .with_column((col("estimated_distance_m") - col("distance_m")).alias("distance_error_m"))
        .collect()?;

    println!("{}", df_agg);

    let dir_name = data_dir_path
        .file_name()
        .and_then(|os_str| os_str.to_str())
        .ok_or(error::Error::GetFileName)?;
    let mut df_cols = df_agg
        .lazy()
        .select([
            col("distance_m"),
            col("avg_rssi_dbm"),
            col("estimated_distance_m"),
        ])
        .collect()?
        .take_columns()
        .into_iter()
        .map(|series| {
            series
                .f64()
                .unwrap()
                .into_no_null_iter()
                .collect::<Vec<f64>>()
        })
        .collect::<Vec<Vec<f64>>>();
    let distance_vec = df_cols.remove(0);
    let rssi_vec = df_cols.remove(0);
    create_graph(
        args.graph_args,
        dir_name,
        distance_vec
            .into_iter()
            .zip(rssi_vec.clone().into_iter())
            .collect(),
        df_cols
            .remove(0)
            .into_iter()
            .zip(rssi_vec.into_iter())
            .collect(),
    )
    .map_err(|err| error::Error::DynamicError(err))?;

    return Ok(());
}

fn create_graph(
    graph_args: cli::GraphArgs,
    experiment_name: &str,
    measured: Vec<(f64, f64)>,
    estimated: Vec<(f64, f64)>,
) -> std::result::Result<(), Box<dyn std::error::Error>> {
    let sans_font = graph_args.sans_font.unwrap_or(String::from("sans-serif"));
    let filename = format!("distance_{experiment_name}.svg");
    let root = SVGBackend::new(Path::new(&filename), (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;
    let x_max = measured
        .iter()
        .fold(0f64, |akku, (x, _)| cmp::max_by(akku, *x, f64::total_cmp))
        .div(10.0)
        .ceil()
        .mul(10.0);
    let y_min = measured
        .iter()
        .fold(0f64, |akku, (_, y)| cmp::min_by(akku, *y, f64::total_cmp))
        .div(10.0)
        .floor()
        .mul(10.0);
    let mut chart = ChartBuilder::on(&root)
        .margin(50)
        .set_label_area_size(LabelAreaPosition::Left, 70)
        .set_label_area_size(LabelAreaPosition::Top, 30)
        .build_cartesian_2d(0f64..x_max, y_min..0f64)?;
    chart
        .configure_mesh()
        .x_desc("distance [m]")
        .y_desc("avg. RSSI [dbm]")
        .axis_desc_style((sans_font.as_str(), 20, &BLACK))
        .label_style((sans_font.as_str(), 20, &BLACK))
        .max_light_lines(0)
        .x_labels((x_max / 5.0).trunc() as usize)
        .y_labels((y_min.abs() / 5.0).trunc() as usize)
        .draw()?;

    println!(
        "xmax: {}, ymin: {}, xlabels: {}, ylabels: {}",
        x_max,
        y_min,
        (x_max / 10.0).trunc() as usize,
        (y_min.abs() / 10.0).trunc() as usize
    );

    chart
        .draw_series(PointSeries::of_element(measured, 5, &RED, &|c, s, st| {
            return EmptyElement::at(c) + Cross::new((0, 0), s, st.stroke_width(2));
        }))?
        .label("measured")
        .legend(|(x, y)| Cross::new((x + 10, y), 5, RED.stroke_width(2)));

    chart
        .draw_series(LineSeries::new(estimated, &BLACK))?
        .label("estimated")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &BLACK));

    chart
        .configure_series_labels()
        .label_font((sans_font.as_str(), 20, &BLACK))
        .border_style(&BLACK)
        .background_style(&WHITE.mix(0.8))
        .draw()?;

    root.present()?;

    Ok(())
}
