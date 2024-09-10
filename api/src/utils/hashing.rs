extern crate bcrypt;

use bcrypt::{DEFAULT_COST, hash};

// Uses bcrypt to hash the input parameters
pub fn bcrypt_hash(input: &str) -> Option<String> {
    if let Ok(h) = hash(input, DEFAULT_COST) { 
        return Some(h);
    } else { 
        return None;
    }
}