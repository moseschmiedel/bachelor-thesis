use clap::Parser;

mod cli;
mod distance;
mod error;

fn main() -> error::Result<()> {
    let args = cli::ArgParser::parse();

    match args.command {
        cli::Command::DistanceEvaluation(args) => distance::run_evaluation(args),
        cli::Command::PositionEvaluation(args) => position_evaluation(args),
    }
}

fn position_evaluation(args: cli::PositionArgs) -> error::Result<()> {
    Ok(())
}
