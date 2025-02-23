# guacamole-api-scripts
a collection of Bash scripts that interact with the Guacamole REST API to automate administrative tasks such as managing connections, creating users, and updating permissions. Simplify remote access management through API-driven automation.

## Prerequisites

Before running these scripts, ensure you have:

- **curl** – for making API requests.
- **jq** – for processing JSON data.

Each script checks for `curl` and `jq` and will attempt to install them using `apt` if they are not found.

## Configuration

Each script requires you to update some configuration variables at the top, such as:

- `GUACAMOLE_URL` – the base URL of your Guacamole instance.
- `USERNAME` and `PASSWORD` – credentials to authenticate with the API.
- Additional parameters (like connection details or user information) for the respective tasks.

## Scripts

### get_connections.sh
This script authenticates with the Guacamole API and retrieves the list of all existing connections. The output is formatted with `jq`.

#### Usage

```bash
./get_connections.sh
```

### new_connection.sh
This script creates a single new Guacamole connection using a JSON payload defined within the script. Customize the payload to match your connection details.

#### Usage

```bash
./new_connection.sh
```

### new_user_api.sh
This script creates a new API user (for example, api_connections) and assigns the necessary system permissions for managing connections. Modify the credentials and permissions as needed.

#### Usage

```bash
./new_user_api.sh
```

### new_connections.sh
This script imports multiple new connections from a JSON file. The JSON file should contain an array of connection definitions. A sample file (connections_example.json) is provided.

#### Usage

```bash
./new_connections.sh -f /path/to/your/connections.json
```

### rm_all_connections.sh
This script retrieves all connections from the Guacamole API and deletes them one by one. Use with caution as this will remove all connections from your Guacamole instance.

#### Usage
```bash
./rm_all_connections.sh
```

### Example JSON File
The connections_example.json file contains a sample JSON array with multiple connection definitions. Update this file to match your environment and then use it with the new_connections.sh script.