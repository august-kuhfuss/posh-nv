# eNVenta Scripts

requires TOML Parser

```powershell
Install-Module -Name PSToml -Scope CurrentUser
```

example config:

```toml
# ./config.toml

hosts      = ["broker", "broker-test"]
printHosts = ["print1", "print2"]

[repo]
host     = 'repo'
database = 'NVRep'
user     = 'user'
password = 'p4ssw0rd'

[[packages]]
name    = "eNVenta"
version = "4.5"
labelId = "b0c13fc734c54f1592aaf5ebbaf80a06"

[[settings]]
name          = "base"
version       = "4.5"
package       = "b0c13fc734c54f1592aaf5ebbaf80a06"
configuration = "[PROD] Application"
host          = "broker"

[[settings]]
name          = "base-beta"
version       = "4.5"
package       = "b0c13fc734c54f1592aaf5ebbaf80a06"
configuration = "[BETA] Application"
host          = "broker-test"

[[packages]]
name    = "pack1"
version = "4.5"
labelId = "abc123"

[[settings]]
name          = "app-1"
version       = "4.5"
package       = "abc123"
configuration = "[PROD] Application 1"
host          = "broker"

[[settings]]
name          = "app-2"
version       = "4.5"
package       = "abc123"
configuration = "[PROD] Application 2"
host          = "broker"

[[settings]]
name          = "app-lb"
version       = "4.5"
package       = "abc123"
configuration = "[PROD] Application Load Balancer"
host          = "broker"

[[settings]]
name          = "beta"
version       = "4.5"
package       = "abc123"
configuration = "[BETA] Application"
host          = "broker-test"

[[settings]]
name          = "services"
version       = "4.5"
package       = "abc123"
configuration = "[PROD] Services"
host          = "broker"

```
