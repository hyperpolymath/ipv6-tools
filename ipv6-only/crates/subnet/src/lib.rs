//! IPv6 subnet calculator and network planning utilities.

use ipv6_only_core::{IPv6Network, Ipv6Error, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Information about a subnet.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubnetInfo {
    pub network: String,
    pub network_address: String,
    pub first_address: String,
    pub last_address: String,
    pub prefix_length: u8,
    pub num_addresses: String,
    pub netmask: String,
}

impl SubnetInfo {
    fn from_network(net: &IPv6Network) -> Self {
        Self {
            network: net.to_string(),
            network_address: net.network_address().compressed(),
            first_address: net.network_address().compressed(),
            last_address: net.broadcast_address().compressed(),
            prefix_length: net.prefix_len(),
            num_addresses: net.num_addresses().to_string(),
            netmask: net.netmask().exploded(),
        }
    }
}

/// Calculator for IPv6 subnet operations and planning.
pub struct IPv6SubnetCalculator {
    network: IPv6Network,
}

impl IPv6SubnetCalculator {
    /// Initialize subnet calculator with a network.
    pub fn new(network: &str) -> Result<Self> {
        let network = IPv6Network::new(network)?;
        Ok(Self { network })
    }

    /// Get detailed information about the network.
    pub fn get_info(&self) -> SubnetInfo {
        SubnetInfo::from_network(&self.network)
    }

    /// Divide the network into a specified number of subnets.
    pub fn divide_into_subnets(&self, num_subnets: usize) -> Result<Vec<SubnetInfo>> {
        if num_subnets < 1 {
            return Err(Ipv6Error::DivisionError(
                "Number of subnets must be at least 1".to_string(),
            ));
        }

        // Calculate required prefix length
        let bits_needed = (num_subnets as f64).log2().ceil() as u8;
        let new_prefix = self.network.prefix_len() + bits_needed;

        if new_prefix > 128 {
            return Err(Ipv6Error::DivisionError(format!(
                "Cannot divide into {} subnets - would exceed /128",
                num_subnets
            )));
        }

        let subnets = self.network.subnets(bits_needed)?;
        Ok(subnets
            .into_iter()
            .take(num_subnets)
            .map(|net| SubnetInfo::from_network(&net))
            .collect())
    }

    /// Divide the network by specifying new prefix length.
    pub fn divide_by_prefix(&self, new_prefix: u8) -> Result<Vec<SubnetInfo>> {
        if new_prefix <= self.network.prefix_len() {
            return Err(Ipv6Error::DivisionError(format!(
                "New prefix must be larger than current prefix /{}",
                self.network.prefix_len()
            )));
        }

        if new_prefix > 128 {
            return Err(Ipv6Error::InvalidPrefix(
                "Prefix length cannot exceed 128".to_string(),
            ));
        }

        let prefixlen_diff = new_prefix - self.network.prefix_len();
        let subnets = self.network.subnets(prefixlen_diff)?;
        Ok(subnets
            .into_iter()
            .map(|net| SubnetInfo::from_network(&net))
            .collect())
    }

    /// Get the supernet with specified prefix length.
    pub fn get_supernet(&self, new_prefix: u8) -> Result<SubnetInfo> {
        if new_prefix >= self.network.prefix_len() {
            return Err(Ipv6Error::DivisionError(format!(
                "New prefix must be smaller than current prefix /{}",
                self.network.prefix_len()
            )));
        }

        let prefixlen_diff = self.network.prefix_len() - new_prefix;
        let supernet = self.network.supernet(prefixlen_diff)?;
        Ok(SubnetInfo::from_network(&supernet))
    }

    /// Check if an address is within this network.
    pub fn contains_address(&self, address: &str) -> bool {
        use ipv6_only_core::IPv6Address;
        match IPv6Address::new(address) {
            Ok(addr) => self.network.contains(&addr),
            Err(_) => false,
        }
    }

    /// Check if this network overlaps with another.
    pub fn overlaps_with(&self, other_network: &str) -> bool {
        match IPv6Network::new(other_network) {
            Ok(other) => self.network.overlaps(&other),
            Err(_) => false,
        }
    }

    /// Recommend subnet allocation based on department sizes.
    pub fn recommend_allocation(
        total_prefix: &str,
        department_counts: &HashMap<String, usize>,
    ) -> Result<HashMap<String, Vec<SubnetInfo>>> {
        let network = IPv6Network::new(total_prefix)?;

        // Calculate total subnets needed
        let total_needed: usize = department_counts.values().sum();

        // Find appropriate prefix length
        let bits_needed = (total_needed as f64).log2().ceil() as u8;
        let subnet_prefix = network.prefix_len() + bits_needed;

        if subnet_prefix > 128 {
            return Err(Ipv6Error::DivisionError(format!(
                "Cannot allocate {} subnets from {}",
                total_needed, total_prefix
            )));
        }

        // Generate all subnets
        let all_subnets = network.subnets(bits_needed)?;

        // Allocate to departments
        let mut allocation = HashMap::new();
        let mut current_index = 0;

        let mut sorted_depts: Vec<_> = department_counts.iter().collect();
        sorted_depts.sort_by_key(|(name, _)| *name);

        for (dept_name, count) in sorted_depts {
            if current_index + count > all_subnets.len() {
                return Err(Ipv6Error::DivisionError(format!(
                    "Not enough subnets for department {}",
                    dept_name
                )));
            }

            let dept_subnets: Vec<SubnetInfo> = all_subnets[current_index..current_index + count]
                .iter()
                .map(|net| SubnetInfo::from_network(net))
                .collect();

            allocation.insert(dept_name.clone(), dept_subnets);
            current_index += count;
        }

        Ok(allocation)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculator_info() {
        let calc = IPv6SubnetCalculator::new("2001:db8::/32").unwrap();
        let info = calc.get_info();
        assert_eq!(info.prefix_length, 32);
        assert_eq!(info.network_address, "2001:db8::");
    }

    #[test]
    fn test_divide_into_subnets() {
        let calc = IPv6SubnetCalculator::new("2001:db8::/32").unwrap();
        let subnets = calc.divide_into_subnets(4).unwrap();
        assert_eq!(subnets.len(), 4);
        assert_eq!(subnets[0].prefix_length, 34);
    }

    #[test]
    fn test_contains_address() {
        let calc = IPv6SubnetCalculator::new("2001:db8::/32").unwrap();
        assert!(calc.contains_address("2001:db8::1"));
        assert!(!calc.contains_address("2001:db9::1"));
    }

    #[test]
    fn test_supernet() {
        let calc = IPv6SubnetCalculator::new("2001:db8::/32").unwrap();
        let supernet = calc.get_supernet(24).unwrap();
        assert_eq!(supernet.prefix_length, 24);
    }
}
