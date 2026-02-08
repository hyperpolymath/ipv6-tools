//! IPv6 utility functions for address manipulation and generation.

use ipv6_only_core::{IPv6Address, IPv6Network, Ipv6Error, Result};
use rand::Rng;
use std::net::Ipv6Addr;

/// Compress an IPv6 address to its shortest form.
pub fn compress_address(address: &str) -> Result<String> {
    let addr = IPv6Address::new(address)?;
    Ok(addr.compressed())
}

/// Expand an IPv6 address to its full form.
pub fn expand_address(address: &str) -> Result<String> {
    let addr = IPv6Address::new(address)?;
    Ok(addr.exploded())
}

/// Generate an IPv6 link-local address (fe80::/10).
pub fn generate_link_local(interface_id: Option<&str>) -> Result<String> {
    let iid = match interface_id {
        Some(id) => {
            let clean = id.replace([':', '-'], "");
            if clean.len() != 16 {
                return Err(Ipv6Error::InvalidAddress(
                    "Interface ID must be 64 bits (16 hex characters)".to_string(),
                ));
            }
            hex::decode(&clean).map_err(|_| {
                Ipv6Error::InvalidAddress("Invalid hex in interface ID".to_string())
            })?
        }
        None => {
            let mut rng = rand::thread_rng();
            let mut bytes = [0u8; 8];
            rng.fill(&mut bytes);
            bytes.to_vec()
        }
    };

    // Build fe80::xxxx:xxxx:xxxx:xxxx
    let mut octets = [0u8; 16];
    octets[0] = 0xfe;
    octets[1] = 0x80;
    octets[8..16].copy_from_slice(&iid);

    let addr = Ipv6Addr::from(octets);
    Ok(addr.to_string())
}

/// Generate a Unique Local Address (ULA) in the fd00::/8 range.
pub fn generate_unique_local(
    global_id: Option<&str>,
    subnet_id: Option<&str>,
    interface_id: Option<&str>,
) -> Result<String> {
    let gid = match global_id {
        Some(id) => {
            let clean = id.replace([':', '-'], "");
            if clean.len() != 10 {
                return Err(Ipv6Error::InvalidAddress(
                    "Global ID must be 40 bits (10 hex characters)".to_string(),
                ));
            }
            hex::decode(&clean)
                .map_err(|_| Ipv6Error::InvalidAddress("Invalid hex in global ID".to_string()))?
        }
        None => {
            let mut rng = rand::thread_rng();
            let mut bytes = [0u8; 5];
            rng.fill(&mut bytes);
            bytes.to_vec()
        }
    };

    let sid = match subnet_id {
        Some(id) => {
            let clean = id.replace([':', '-'], "");
            if clean.len() != 4 {
                return Err(Ipv6Error::InvalidAddress(
                    "Subnet ID must be 16 bits (4 hex characters)".to_string(),
                ));
            }
            hex::decode(&clean)
                .map_err(|_| Ipv6Error::InvalidAddress("Invalid hex in subnet ID".to_string()))?
        }
        None => {
            let mut rng = rand::thread_rng();
            let mut bytes = [0u8; 2];
            rng.fill(&mut bytes);
            bytes.to_vec()
        }
    };

    let iid = match interface_id {
        Some(id) => {
            let clean = id.replace([':', '-'], "");
            if clean.len() != 16 {
                return Err(Ipv6Error::InvalidAddress(
                    "Interface ID must be 64 bits (16 hex characters)".to_string(),
                ));
            }
            hex::decode(&clean).map_err(|_| {
                Ipv6Error::InvalidAddress("Invalid hex in interface ID".to_string())
            })?
        }
        None => {
            let mut rng = rand::thread_rng();
            let mut bytes = [0u8; 8];
            rng.fill(&mut bytes);
            bytes.to_vec()
        }
    };

    // Build fd + 40-bit global + 16-bit subnet + 64-bit interface
    let mut octets = [0u8; 16];
    octets[0] = 0xfd;
    octets[1..6].copy_from_slice(&gid);
    octets[6..8].copy_from_slice(&sid);
    octets[8..16].copy_from_slice(&iid);

    let addr = Ipv6Addr::from(octets);
    Ok(addr.to_string())
}

/// Generate a random IPv6 address with given prefix.
pub fn generate_random_ipv6(prefix: &str) -> Result<String> {
    let prefix_with_len = if prefix.contains('/') {
        prefix.to_string()
    } else {
        format!("{}/64", prefix)
    };

    let network = IPv6Network::new(&prefix_with_len)?;
    let prefix_len = network.prefix_len();

    let host_bits = 128 - prefix_len;
    let mut rng = rand::thread_rng();

    // Generate random host part
    let random_host: u128 = if host_bits >= 64 {
        let high: u64 = rng.gen();
        let low: u64 = rng.gen();
        ((high as u128) << 64) | (low as u128)
    } else {
        rng.gen::<u128>()
    };
    let host_mask = if host_bits == 128 {
        u128::MAX
    } else {
        (1u128 << host_bits) - 1
    };
    let masked_host = random_host & host_mask;

    // Combine with network
    let network_int = network.network_address().to_u128();
    let address_int = network_int | masked_host;

    let addr = Ipv6Addr::from(address_int);
    Ok(addr.to_string())
}

/// Generate reverse DNS pointer (PTR) record name for IPv6 address.
pub fn reverse_pointer(address: &str) -> Result<String> {
    let addr = IPv6Address::new(address)?;
    let hex = addr.to_hex();

    let reversed: String = hex
        .chars()
        .rev()
        .enumerate()
        .flat_map(|(i, c)| {
            if i > 0 {
                vec!['.', c]
            } else {
                vec![c]
            }
        })
        .collect();

    Ok(format!("{}.ip6.arpa", reversed))
}

/// Convert MAC address to IPv6 link-local address using EUI-64.
pub fn mac_to_ipv6_link_local(mac: &str) -> Result<String> {
    let clean = mac
        .replace([':', '-', '.'], "")
        .to_lowercase();

    if clean.len() != 12 {
        return Err(Ipv6Error::InvalidAddress(
            "Invalid MAC address length".to_string(),
        ));
    }

    let mac_bytes = hex::decode(&clean)
        .map_err(|_| Ipv6Error::InvalidAddress("Invalid MAC address format".to_string()))?;

    // Convert to EUI-64: insert FFFE in middle and flip U/L bit
    let mut eui64 = [0u8; 8];
    eui64[0] = mac_bytes[0] ^ 0x02; // Flip universal/local bit
    eui64[1] = mac_bytes[1];
    eui64[2] = mac_bytes[2];
    eui64[3] = 0xff;
    eui64[4] = 0xfe;
    eui64[5] = mac_bytes[3];
    eui64[6] = mac_bytes[4];
    eui64[7] = mac_bytes[5];

    // Build link-local address
    let mut octets = [0u8; 16];
    octets[0] = 0xfe;
    octets[1] = 0x80;
    octets[8..16].copy_from_slice(&eui64);

    let addr = Ipv6Addr::from(octets);
    Ok(addr.to_string())
}

/// Calculate the subnet mask for a given prefix length.
pub fn calculate_subnet_mask(prefix_length: u8) -> Result<String> {
    if prefix_length > 128 {
        return Err(Ipv6Error::InvalidPrefix(format!(
            "Prefix length {} exceeds 128",
            prefix_length
        )));
    }

    let network = IPv6Network::new(&format!("::/{}", prefix_length))?;
    Ok(network.netmask().exploded())
}

/// Validate IPv6 address and return error message if invalid.
pub fn validate_ipv6(address: &str, allow_zone: bool) -> (bool, Option<String>) {
    if address.is_empty() {
        return (false, Some("Address cannot be empty".to_string()));
    }

    if address.contains('%') && !allow_zone {
        return (false, Some("Zone IDs are not allowed".to_string()));
    }

    match IPv6Address::new(address) {
        Ok(_) => (true, None),
        Err(e) => (false, Some(e.to_string())),
    }
}

/// Validate IPv6 network and return error message if invalid.
pub fn validate_ipv6_network(network: &str) -> (bool, Option<String>) {
    if network.is_empty() {
        return (false, Some("Network cannot be empty".to_string()));
    }

    if !network.contains('/') {
        return (
            false,
            Some("Network must include prefix length (e.g., 2001:db8::/32)".to_string()),
        );
    }

    match IPv6Network::new(network) {
        Ok(_) => (true, None),
        Err(e) => (false, Some(e.to_string())),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compress_expand() {
        let compressed = compress_address("2001:0db8:0000:0000:0000:0000:0000:0001").unwrap();
        assert_eq!(compressed, "2001:db8::1");

        let expanded = expand_address("2001:db8::1").unwrap();
        assert_eq!(expanded, "2001:0db8:0000:0000:0000:0000:0000:0001");
    }

    #[test]
    fn test_mac_to_link_local() {
        let addr = mac_to_ipv6_link_local("00:11:22:33:44:55").unwrap();
        assert!(addr.starts_with("fe80::"));
    }

    #[test]
    fn test_reverse_pointer() {
        let ptr = reverse_pointer("2001:db8::1").unwrap();
        assert!(ptr.ends_with(".ip6.arpa"));
    }

    #[test]
    fn test_validation() {
        let (valid, _) = validate_ipv6("2001:db8::1", true);
        assert!(valid);

        let (valid, err) = validate_ipv6("invalid", true);
        assert!(!valid);
        assert!(err.is_some());
    }
}
