use linreg;
use plotters::prelude::DrawingAreaErrorKind;
use polars::prelude::PolarsError;
use std::{ffi, io, num};

#[derive(Debug)]
pub enum Error {
    GetFileName,
    IoError(io::Error),
    PolarsError(PolarsError),
    OsStringConversionError(ffi::OsString),
    ParseFloatError(num::ParseFloatError),
    LinRegError(linreg::Error),
    DynamicError(Box<dyn std::error::Error>),
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

impl From<linreg::Error> for Error {
    fn from(value: linreg::Error) -> Self {
        Self::LinRegError(value)
    }
}

pub type Result<T> = std::result::Result<T, Error>;
