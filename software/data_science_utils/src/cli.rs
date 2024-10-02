use clap::{command, Args, Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about=None)]
#[command(propagate_version = true)]
pub struct ArgParser {
    /// Command to execute
    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand, Clone)]
pub enum Command {
    DistanceEvaluation(DistanceArgs),
    PositionEvaluation(PositionArgs),
}

#[derive(Args, Clone)]
pub struct DistanceArgs {
    /// Directory where the data to operate on is stored
    pub data_dir: String,
    /// Minimum distance to include in the RSSI model
    #[arg(short, long)]
    pub min_distance: Option<f64>,
    #[command(flatten)]
    pub graph_args: GraphArgs,
}

#[derive(Args, Clone)]
pub struct GraphArgs {
    /// Serif font to use when drawing graph
    #[arg(long = "serif-font")]
    pub serif_font: Option<String>,
    /// Sans-serif font to use when drawing graph
    #[arg(long = "sans-font")]
    pub sans_font: Option<String>,
}

#[derive(Args, Clone)]
pub struct PositionArgs {
    /// Directory where the data to operate on is stored
    pub data_dir: String,
}
