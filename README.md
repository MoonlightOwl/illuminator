![image](http://fomalhaut.me:1095/images/logo.png)

# illuminator

Web interface for IRC logs from channel #CC.RU on Esper.Net.

You can find the working beta [here](http://fomalhaut.me:1095/).

# installation

1. First you will need Crystal compiler installed. Refer to [this](https://crystal-lang.org/docs/installation/) page for details.
2. Then clone this project repository:
```sh
$ git clone https://github.com/MoonlightOwl/illuminator.git
```
3. Go to the project folder:
```sh
$ cd illuminator/
```
4. Download dependencies:
```sh
$ shards install
```
5. Build binary file in `release` mode:
```sh
crystal build --release --no-debug src/illuminator.cr
```
6. Now you can run `./illuminator` file directly from this folder, or take `./illuminator` file and `./config/`, `./public/` folders anywhere you want to deploy the server.
7. To define server port and the path to irc log files you need to change the `./config/illuminator.conf` file.
Example:
```ini
port:1095
path:./logs/
```
8. To run illuminator server in production mode you will need to define environment variable `KEMAL_ENV`:
```sh
KEMAL_ENV=production ./illuminator 
```

# contribution

Feel free to make any contributions and corrections, as this is my first Crystal project, and I don't know the language good enough.
