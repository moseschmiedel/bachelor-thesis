use clap::Parser;
use polars::prelude::*;
use polars_arrow::array::Utf8ViewArray;
use std::{ffi::OsString, fs, io, path::Path};

#[derive(Parser)]
#[command(author, version, about, long_about=None)]
struct Cli {
    /// Directory where the data to operate on is stored
    data_dir: String,
}

#[derive(Debug)]
enum Error {
    IoError(io::Error),
    PolarsError(PolarsError),
    OsStringConversionError(std::ffi::OsString),
    ParseFloatError(std::num::ParseFloatError),
}

impl From<io::Error> for Error {
    fn from(value: io::Error) -> Self {
        Self::IoError(value)
    }
}

impl From<PolarsError> for Error {
    fn from(value: PolarsError) -> Self {
        Self::PolarsError(value)
    }
}

impl From<std::num::ParseFloatError> for Error {
    fn from(value: std::num::ParseFloatError) -> Self {
        Self::ParseFloatError(value)
    }
}

fn main() -> Result<(), Error> {
    let args = Cli::parse();
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
        .collect()?;
    df_agg.set_column_names(&["distance_m", "avg_rssi_dbm"])?;

    println!("{}", df_agg);

    return Ok(());
}
