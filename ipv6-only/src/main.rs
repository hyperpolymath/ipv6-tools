//! ipv6-only CLI
//!
//! IPv6 address manipulation, subnet calculation, and network planning tools.

use clap::{Parser, Subcommand};
use ipv6_only_core::{IPv6Address, IPv6Network};
use ipv6_only_subnet::IPv6SubnetCalculator;
use ipv6_only_utils::{
    compress_address, expand_address, generate_link_local, generate_random_ipv6,
    generate_unique_local, mac_to_ipv6_link_local, reverse_pointer, validate_ipv6,
    validate_ipv6_network,
};
use std::collections::HashMap;

#[derive(Parser)]
#[command(name = "ipv6")]
#[command(author = "Jonathan D.A. Jewell")]
#[command(version)]
#[command(about = "IPv6 address manipulation, subnet calculation, and network planning", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Output format (text or json)
    #[arg(short, long, default_value = "text", global = true)]
    format: String,
}

#[derive(Subcommand)]
enum Commands {
    /// Calculate subnet information
    Calc {
        /// IPv6 network in CIDR notation
        network: String,

        /// Show network info
        #[arg(short, long)]
        info: bool,

        /// Divide into N subnets
        #[arg(short, long)]
        divide: Option<usize>,

        /// Divide by prefix length
        #[arg(short, long)]
        prefix: Option<u8>,

        /// Get supernet with prefix length
        #[arg(short, long)]
        supernet: Option<u8>,

        /// Check if address is in network
        #[arg(short, long)]
        contains: Option<String>,
    },

    /// Validate IPv6 addresses or networks
    Validate {
        /// IPv6 addresses or networks to validate
        #[arg(required = true)]
        input: Vec<String>,

        /// Validate as network
        #[arg(short, long)]
        network: bool,

        /// Quiet mode (exit code only)
        #[arg(short, long)]
        quiet: bool,

        /// Disallow zone IDs
        #[arg(long)]
        no_zone: bool,
    },

    /// Generate IPv6 addresses
    Generate {
        #[command(subcommand)]
        gen_type: GenerateType,

        /// Number of addresses to generate
        #[arg(short, long, default_value = "1", global = true)]
        count: usize,
    },

    /// Convert IPv6 address formats
    Convert {
        /// IPv6 address to convert
        address: String,

        /// Compress address
        #[arg(short, long)]
        compress: bool,

        /// Expand address
        #[arg(short, long)]
        expand: bool,

        /// Generate reverse DNS
        #[arg(short, long)]
        reverse: bool,

        /// Show binary representation
        #[arg(short, long)]
        binary: bool,

        /// Show hex representation
        #[arg(short = 'x', long)]
        hex: bool,

        /// Show all formats
        #[arg(short, long)]
        all: bool,
    },

    /// Analyze IPv6 address
    Analyze {
        /// IPv6 address to analyze
        address: String,
    },
}

#[derive(Subcommand)]
enum GenerateType {
    /// Generate link-local address
    LinkLocal {
        /// Interface ID (64 bits hex)
        #[arg(short, long)]
        interface_id: Option<String>,
    },

    /// Generate unique local address (ULA)
    Ula {
        /// Global ID (40 bits hex)
        #[arg(short, long)]
        global_id: Option<String>,

        /// Subnet ID (16 bits hex)
        #[arg(short, long)]
        subnet_id: Option<String>,

        /// Interface ID (64 bits hex)
        #[arg(short, long)]
        interface_id: Option<String>,
    },

    /// Generate random address in prefix
    Random {
        /// Prefix to use
        #[arg(short, long, default_value = "2001:db8::/64")]
        prefix: String,
    },

    /// Generate from MAC address
    FromMac {
        /// MAC address
        mac: String,
    },
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Calc {
            network,
            info,
            divide,
            prefix,
            supernet,
            contains,
        } => {
            let calc = IPv6SubnetCalculator::new(&network)?;

            if info || (divide.is_none() && prefix.is_none() && supernet.is_none() && contains.is_none()) {
                let net_info = calc.get_info();
                if cli.format == "json" {
                    println!("{}", serde_json::to_string_pretty(&net_info)?);
                } else {
                    println!("Network: {}", net_info.network);
                    println!("Network Address: {}", net_info.network_address);
                    println!("First Address: {}", net_info.first_address);
                    println!("Last Address: {}", net_info.last_address);
                    println!("Prefix Length: /{}", net_info.prefix_length);
                    println!("Number of Addresses: {}", net_info.num_addresses);
                    println!("Netmask: {}", net_info.netmask);
                }
            }

            if let Some(num) = divide {
                let subnets = calc.divide_into_subnets(num)?;
                if cli.format == "json" {
                    println!("{}", serde_json::to_string_pretty(&subnets)?);
                } else {
                    println!("\nSubnets ({}):", subnets.len());
                    for (i, subnet) in subnets.iter().enumerate() {
                        println!("  {}: {} ({} addresses)", i + 1, subnet.network, subnet.num_addresses);
                    }
                }
            }

            if let Some(new_prefix) = prefix {
                let subnets = calc.divide_by_prefix(new_prefix)?;
                println!("\nCreated {} subnets with /{}:", subnets.len(), new_prefix);
                for subnet in subnets.iter().take(10) {
                    println!("  {}", subnet.network);
                }
                if subnets.len() > 10 {
                    println!("  ... and {} more", subnets.len() - 10);
                }
            }

            if let Some(new_prefix) = supernet {
                let super_info = calc.get_supernet(new_prefix)?;
                println!("\nSupernet: {}", super_info.network);
                println!("Network Address: {}", super_info.network_address);
                println!("Prefix Length: /{}", super_info.prefix_length);
            }

            if let Some(addr) = contains {
                let in_network = calc.contains_address(&addr);
                println!("{} is {} {}", addr, if in_network { "in" } else { "not in" }, network);
            }
        }

        Commands::Validate {
            input,
            network,
            quiet,
            no_zone,
        } => {
            let mut all_valid = true;

            for addr in input {
                let (valid, error) = if network {
                    validate_ipv6_network(&addr)
                } else {
                    validate_ipv6(&addr, !no_zone)
                };

                if !quiet {
                    if valid {
                        println!("\u{2713} {} is valid", addr);
                    } else {
                        println!("\u{2717} {} is invalid: {}", addr, error.unwrap_or_default());
                    }
                }

                if !valid {
                    all_valid = false;
                }
            }

            if !all_valid {
                std::process::exit(1);
            }
        }

        Commands::Generate { gen_type, count } => {
            for _ in 0..count {
                let addr = match &gen_type {
                    GenerateType::LinkLocal { interface_id } => {
                        generate_link_local(interface_id.as_deref())?
                    }
                    GenerateType::Ula {
                        global_id,
                        subnet_id,
                        interface_id,
                    } => generate_unique_local(
                        global_id.as_deref(),
                        subnet_id.as_deref(),
                        interface_id.as_deref(),
                    )?,
                    GenerateType::Random { prefix } => generate_random_ipv6(prefix)?,
                    GenerateType::FromMac { mac } => mac_to_ipv6_link_local(mac)?,
                };
                println!("{}", addr);
            }
        }

        Commands::Convert {
            address,
            compress,
            expand,
            reverse,
            binary,
            hex,
            all,
        } => {
            let addr = IPv6Address::new(&address)?;

            if all {
                println!("Compressed:  {}", addr.compressed());
                println!("Expanded:    {}", addr.exploded());
                println!("Binary:      {}", addr.to_binary());
                println!("Hexadecimal: {}", addr.to_hex());
                println!("Reverse DNS: {}", reverse_pointer(&address)?);
                println!("Type:        {}", addr.address_type());
            } else {
                let mut any = false;
                if compress {
                    println!("{}", compress_address(&address)?);
                    any = true;
                }
                if expand {
                    println!("{}", expand_address(&address)?);
                    any = true;
                }
                if reverse {
                    println!("{}", reverse_pointer(&address)?);
                    any = true;
                }
                if binary {
                    println!("{}", addr.to_binary());
                    any = true;
                }
                if hex {
                    println!("{}", addr.to_hex());
                    any = true;
                }
                if !any {
                    println!("{}", addr.compressed());
                }
            }
        }

        Commands::Analyze { address } => {
            let addr = IPv6Address::new(&address)?;
            println!("Address: {}", addr.compressed());
            println!("Type: {}", addr.address_type());
            println!("Expanded: {}", addr.exploded());
            println!();
            println!("Properties:");
            println!("  Loopback:     {}", addr.is_loopback());
            println!("  Link-Local:   {}", addr.is_link_local());
            println!("  Unique Local: {}", addr.is_unique_local());
            println!("  Multicast:    {}", addr.is_multicast());
            println!("  Global:       {}", addr.is_global());
            println!("  Unspecified:  {}", addr.is_unspecified());
            if let Some(zone) = addr.zone_id() {
                println!("  Zone ID:      {}", zone);
            }
        }
    }

    Ok(())
}
