//! Core IPv6 types for ipv6-only
//!
//! Provides IPv6Address and IPv6Network types with full address manipulation.

use serde::{Deserialize, Serialize};
use std::fmt;
use std::net::Ipv6Addr;
use std::str::FromStr;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Ipv6Error {
    #[error("Invalid IPv6 address: {0}")]
    InvalidAddress(String),
    #[error("Invalid IPv6 network: {0}")]
    InvalidNetwork(String),
    #[error("Invalid prefix length: {0}")]
    InvalidPrefix(String),
    #[error("Network too large to enumerate (prefix < /64)")]
    NetworkTooLarge,
    #[error("Cannot divide network: {0}")]
    DivisionError(String),
}

pub type Result<T> = std::result::Result<T, Ipv6Error>;

/// Represents an IPv6 address with utilities for manipulation and analysis.
#[derive(Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct IPv6Address {
    addr: Ipv6Addr,
    zone_id: Option<String>,
}

impl IPv6Address {
    /// Create a new IPv6 address from a string.
    pub fn new(address: &str) -> Result<Self> {
        let (addr_str, zone_id) = if let Some(idx) = address.find('%') {
            (&address[..idx], Some(address[idx + 1..].to_string()))
        } else {
            (address, None)
        };

        let addr = Ipv6Addr::from_str(addr_str)
            .map_err(|e| Ipv6Error::InvalidAddress(e.to_string()))?;

        Ok(Self { addr, zone_id })
    }

    /// Return compressed form of the address.
    pub fn compressed(&self) -> String {
        let mut result = self.addr.to_string();
        if let Some(ref zone) = self.zone_id {
            result.push('%');
            result.push_str(zone);
        }
        result
    }

    /// Return fully expanded form of the address.
    pub fn exploded(&self) -> String {
        let segments = self.addr.segments();
        let mut result = format!(
            "{:04x}:{:04x}:{:04x}:{:04x}:{:04x}:{:04x}:{:04x}:{:04x}",
            segments[0], segments[1], segments[2], segments[3],
            segments[4], segments[5], segments[6], segments[7]
        );
        if let Some(ref zone) = self.zone_id {
            result.push('%');
            result.push_str(zone);
        }
        result
    }

    /// Check if address is link-local (fe80::/10).
    pub fn is_link_local(&self) -> bool {
        let segments = self.addr.segments();
        (segments[0] & 0xffc0) == 0xfe80
    }

    /// Check if address is loopback (::1).
    pub fn is_loopback(&self) -> bool {
        self.addr.is_loopback()
    }

    /// Check if address is multicast (ff00::/8).
    pub fn is_multicast(&self) -> bool {
        self.addr.is_multicast()
    }

    /// Check if address is global unicast.
    pub fn is_global(&self) -> bool {
        let segments = self.addr.segments();
        // Global unicast: 2000::/3
        (segments[0] & 0xe000) == 0x2000
    }

    /// Check if address is unique local (fc00::/7).
    pub fn is_unique_local(&self) -> bool {
        let segments = self.addr.segments();
        (segments[0] & 0xfe00) == 0xfc00
    }

    /// Check if address is unspecified (::).
    pub fn is_unspecified(&self) -> bool {
        self.addr.is_unspecified()
    }

    /// Convert address to binary representation.
    pub fn to_binary(&self) -> String {
        let octets = self.addr.octets();
        octets.iter().map(|b| format!("{:08b}", b)).collect()
    }

    /// Convert address to hexadecimal representation.
    pub fn to_hex(&self) -> String {
        let octets = self.addr.octets();
        octets.iter().map(|b| format!("{:02x}", b)).collect()
    }

    /// Determine the type of IPv6 address.
    pub fn address_type(&self) -> &'static str {
        if self.is_loopback() {
            "Loopback"
        } else if self.is_link_local() {
            "Link-Local"
        } else if self.is_unique_local() {
            "Unique Local (ULA)"
        } else if self.is_multicast() {
            "Multicast"
        } else if self.is_global() {
            "Global Unicast"
        } else if self.is_unspecified() {
            "Unspecified"
        } else {
            "Reserved"
        }
    }

    /// Get the underlying Ipv6Addr.
    pub fn inner(&self) -> Ipv6Addr {
        self.addr
    }

    /// Get the zone ID if present.
    pub fn zone_id(&self) -> Option<&str> {
        self.zone_id.as_deref()
    }

    /// Convert to u128 for arithmetic.
    pub fn to_u128(&self) -> u128 {
        u128::from(self.addr)
    }
}

impl fmt::Display for IPv6Address {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.compressed())
    }
}

impl fmt::Debug for IPv6Address {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "IPv6Address('{}')", self.compressed())
    }
}

impl FromStr for IPv6Address {
    type Err = Ipv6Error;

    fn from_str(s: &str) -> Result<Self> {
        Self::new(s)
    }
}

/// Represents an IPv6 network with CIDR notation.
#[derive(Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct IPv6Network {
    network_addr: Ipv6Addr,
    prefix_len: u8,
}

impl IPv6Network {
    /// Create a new IPv6 network from CIDR notation.
    pub fn new(network: &str) -> Result<Self> {
        let (addr_str, prefix_str) = network
            .split_once('/')
            .ok_or_else(|| Ipv6Error::InvalidNetwork("Missing prefix length".to_string()))?;

        let prefix_len: u8 = prefix_str
            .parse()
            .map_err(|_| Ipv6Error::InvalidPrefix(prefix_str.to_string()))?;

        if prefix_len > 128 {
            return Err(Ipv6Error::InvalidPrefix(format!(
                "Prefix {} exceeds 128",
                prefix_len
            )));
        }

        let addr = Ipv6Addr::from_str(addr_str)
            .map_err(|e| Ipv6Error::InvalidAddress(e.to_string()))?;

        // Mask to network address
        let mask = Self::prefix_to_mask(prefix_len);
        let network_int = u128::from(addr) & mask;
        let network_addr = Ipv6Addr::from(network_int);

        Ok(Self {
            network_addr,
            prefix_len,
        })
    }

    /// Get network address.
    pub fn network_address(&self) -> IPv6Address {
        IPv6Address {
            addr: self.network_addr,
            zone_id: None,
        }
    }

    /// Get broadcast address (last address in network).
    pub fn broadcast_address(&self) -> IPv6Address {
        let host_mask = Self::prefix_to_host_mask(self.prefix_len);
        let broadcast = u128::from(self.network_addr) | host_mask;
        IPv6Address {
            addr: Ipv6Addr::from(broadcast),
            zone_id: None,
        }
    }

    /// Get network mask.
    pub fn netmask(&self) -> IPv6Address {
        let mask = Self::prefix_to_mask(self.prefix_len);
        IPv6Address {
            addr: Ipv6Addr::from(mask),
            zone_id: None,
        }
    }

    /// Get host mask.
    pub fn hostmask(&self) -> IPv6Address {
        let mask = Self::prefix_to_host_mask(self.prefix_len);
        IPv6Address {
            addr: Ipv6Addr::from(mask),
            zone_id: None,
        }
    }

    /// Get prefix length.
    pub fn prefix_len(&self) -> u8 {
        self.prefix_len
    }

    /// Get total number of addresses in network.
    pub fn num_addresses(&self) -> u128 {
        1u128 << (128 - self.prefix_len)
    }

    /// Check if an address is contained in this network.
    pub fn contains(&self, address: &IPv6Address) -> bool {
        let mask = Self::prefix_to_mask(self.prefix_len);
        let addr_network = u128::from(address.addr) & mask;
        addr_network == u128::from(self.network_addr)
    }

    /// Check if this network overlaps with another.
    pub fn overlaps(&self, other: &IPv6Network) -> bool {
        let self_start = u128::from(self.network_addr);
        let self_end = self_start + self.num_addresses() - 1;
        let other_start = u128::from(other.network_addr);
        let other_end = other_start + other.num_addresses() - 1;

        self_start <= other_end && other_start <= self_end
    }

    /// Generate subnets by dividing this network.
    pub fn subnets(&self, prefixlen_diff: u8) -> Result<Vec<IPv6Network>> {
        let new_prefix = self.prefix_len + prefixlen_diff;
        if new_prefix > 128 {
            return Err(Ipv6Error::DivisionError(format!(
                "New prefix {} would exceed 128",
                new_prefix
            )));
        }

        let num_subnets = 1usize << prefixlen_diff;
        let subnet_size = 1u128 << (128 - new_prefix);
        let base = u128::from(self.network_addr);

        let mut subnets = Vec::with_capacity(num_subnets);
        for i in 0..num_subnets {
            let subnet_addr = Ipv6Addr::from(base + (i as u128 * subnet_size));
            subnets.push(IPv6Network {
                network_addr: subnet_addr,
                prefix_len: new_prefix,
            });
        }

        Ok(subnets)
    }

    /// Get supernet by reducing prefix length.
    pub fn supernet(&self, prefixlen_diff: u8) -> Result<IPv6Network> {
        if prefixlen_diff > self.prefix_len {
            return Err(Ipv6Error::DivisionError(format!(
                "Cannot reduce prefix by {} from /{}",
                prefixlen_diff, self.prefix_len
            )));
        }

        let new_prefix = self.prefix_len - prefixlen_diff;
        let mask = Self::prefix_to_mask(new_prefix);
        let network_int = u128::from(self.network_addr) & mask;

        Ok(IPv6Network {
            network_addr: Ipv6Addr::from(network_int),
            prefix_len: new_prefix,
        })
    }

    fn prefix_to_mask(prefix_len: u8) -> u128 {
        if prefix_len == 0 {
            0
        } else {
            !0u128 << (128 - prefix_len)
        }
    }

    fn prefix_to_host_mask(prefix_len: u8) -> u128 {
        !Self::prefix_to_mask(prefix_len)
    }
}

impl fmt::Display for IPv6Network {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}/{}", self.network_addr, self.prefix_len)
    }
}

impl fmt::Debug for IPv6Network {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "IPv6Network('{}/{}')", self.network_addr, self.prefix_len)
    }
}

impl FromStr for IPv6Network {
    type Err = Ipv6Error;

    fn from_str(s: &str) -> Result<Self> {
        Self::new(s)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_address_parsing() {
        let addr = IPv6Address::new("2001:db8::1").unwrap();
        assert_eq!(addr.compressed(), "2001:db8::1");
        assert_eq!(
            addr.exploded(),
            "2001:0db8:0000:0000:0000:0000:0000:0001"
        );
    }

    #[test]
    fn test_address_with_zone() {
        let addr = IPv6Address::new("fe80::1%eth0").unwrap();
        assert_eq!(addr.zone_id(), Some("eth0"));
        assert!(addr.is_link_local());
    }

    #[test]
    fn test_address_types() {
        assert!(IPv6Address::new("::1").unwrap().is_loopback());
        assert!(IPv6Address::new("fe80::1").unwrap().is_link_local());
        assert!(IPv6Address::new("ff02::1").unwrap().is_multicast());
        assert!(IPv6Address::new("2001:db8::1").unwrap().is_global());
        assert!(IPv6Address::new("fd00::1").unwrap().is_unique_local());
    }

    #[test]
    fn test_network_parsing() {
        let net = IPv6Network::new("2001:db8::/32").unwrap();
        assert_eq!(net.prefix_len(), 32);
        assert_eq!(net.network_address().compressed(), "2001:db8::");
    }

    #[test]
    fn test_network_contains() {
        let net = IPv6Network::new("2001:db8::/32").unwrap();
        assert!(net.contains(&IPv6Address::new("2001:db8::1").unwrap()));
        assert!(!net.contains(&IPv6Address::new("2001:db9::1").unwrap()));
    }

    #[test]
    fn test_subnets() {
        let net = IPv6Network::new("2001:db8::/32").unwrap();
        let subs = net.subnets(4).unwrap();
        assert_eq!(subs.len(), 16);
        assert_eq!(subs[0].prefix_len(), 36);
    }
}
