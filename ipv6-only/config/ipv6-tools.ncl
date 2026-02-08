# IPv6 Tools Configuration
# Nickel configuration file for IPv6-Only Tools
# https://nickel-lang.org/

{
  metadata = {
    version = "0.1.0",
    name = "IPv6-Only Tools",
    description = "Comprehensive IPv6 networking toolkit",
  },

  network = {
    # Default network prefix for examples and testing
    default_prefix = "2001:db8::/32",

    # Documentation prefix (RFC 3849)
    doc_prefix = "2001:db8::/32",

    # Link-local prefix
    link_local_prefix = "fe80::/10",

    # Unique local prefix
    ula_prefix = "fd00::/8",

    # Multicast prefix
    multicast_prefix = "ff00::/8",

    # Common prefix lengths
    prefixes = {
      site = 48,
      subnet = 64,
      host = 128,
    },
  },

  dns = {
    # DNS servers for testing
    servers = [
      { name = "Google", address = "2001:4860:4860::8888" },
      { name = "Google Secondary", address = "2001:4860:4860::8844" },
      { name = "Cloudflare", address = "2606:4700:4700::1111" },
      { name = "Cloudflare Secondary", address = "2606:4700:4700::1001" },
      { name = "Quad9", address = "2620:fe::fe" },
      { name = "Quad9 Secondary", address = "2620:fe::9" },
    ],

    # DNS query timeout
    timeout = 5,

    # Retry attempts
    retries = 3,
  },

  scanning = {
    # Port scanning configuration
    common_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 5432, 8080, 8443],

    # Scan timeout per port
    timeout = 2,

    # Concurrent workers
    max_workers = 50,

    # Rate limiting (requests per second)
    rate_limit = 100,
  },

  benchmarking = {
    # Default iteration count
    default_iterations = 10000,

    # Quick benchmark iterations
    quick_iterations = 1000,

    # Full benchmark iterations
    full_iterations = 50000,

    # Tests to run
    tests = [
      "address_creation",
      "address_validation",
      "compression",
      "expansion",
      "network_operations",
      "subnet_calculation",
    ],
  },

  simulation = {
    # Default network parameters
    default_hosts = 5,
    default_vlans = 3,

    # Random seed for reproducibility
    random_seed | optional = null,
  },

  web = {
    # Web server configuration
    port = 8000,
    host = "localhost",

    # HTTPS settings
    https = {
      enabled = false,
      port = 8443,
      cert_file | optional = "/app/certs/server.crt",
      key_file | optional = "/app/certs/server.key",
    },
  },

  container = {
    # Container configuration
    base_image = "cgr.dev/chainguard/wolfi-base:latest",

    # Exposed ports
    ports = [8000, 8443],

    # Volume mounts
    volumes = ["/data", "/output", "/config"],

    # User
    user = "ipv6tools",
    uid = 1000,
    gid = 1000,
  },

  hurricane_electric = {
    # HE tunnel configuration
    tunnel_server = "tunnelbroker.net",
    api_endpoint = "https://ipv4.tunnelbroker.net/nic/update",

    # Update interval (seconds)
    update_interval = 600,

    # Connection timeout
    timeout = 10,
  },

  logging = {
    # Log level: DEBUG, INFO, WARNING, ERROR, CRITICAL
    level = "INFO",

    # Log format
    format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s",

    # Log file
    file | optional = "/var/log/ipv6-tools.log",

    # Max file size (MB)
    max_size = 10,

    # Backup count
    backup_count = 5,
  },

  security = {
    # Security scanning settings
    max_scan_rate = 1000,  # packets per second
    respect_robots_txt = true,

    # Privacy settings
    enable_privacy_extensions = true,
    temporary_address_lifetime = 86400,  # 24 hours

    # Firewall recommendations
    allow_icmpv6 = true,
    filter_extension_headers = true,
  },

  features = {
    # Feature flags
    enable_dns_tools = true,
    enable_security_scanner = true,
    enable_benchmarking = true,
    enable_simulation = true,
    enable_he_integration = true,
  },

  paths = {
    # Application paths
    data_dir = "/data",
    config_dir = "/config",
    output_dir = "/output",
    cache_dir = "/tmp/ipv6-tools-cache",

    # Tool paths
    bin_dir = "/usr/local/bin",
    scripts_dir = "/usr/local/bin",
  },

  performance = {
    # Performance tuning
    worker_processes = 4,
    thread_pool_size = 10,

    # Caching
    enable_cache = true,
    cache_ttl = 3600,  # 1 hour
    max_cache_size = 1000,  # entries
  },

  examples = {
    # Example networks for demonstrations
    networks = [
      { name = "Enterprise HQ", prefix = "2001:db8:0::/48", description = "Headquarters network" },
      { name = "Data Center", prefix = "2001:db8:100::/48", description = "Primary data center" },
      { name = "Branch Office", prefix = "2001:db8:200::/48", description = "Branch location" },
      { name = "DMZ", prefix = "2001:db8:300::/48", description = "Demilitarized zone" },
    ],
  },
}
