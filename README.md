# simple-snmp-poller
A simple (and poorly written :-) ) snmp poller to help with lab work and investigations



- Installing requirements:

```
sudo apt-get install snmp gnuplot 
```

- Clone the repository

```
git clone https://github.com/dmontagner/simple-snmp-poller
```

- Adjust the file system permissions

```
chmod +x *.pl *.sh
```

- Update the SNMP method, OID and OID descriptions in the file `DB_CPU_MEM_WITH_IDX.DAT`

```
1|GET|.1.3.6.1.4.1.2636.3.1.13.1.11.9.2.0.0|Routing Engine 0 Buffer (%)
2|GET|.1.3.6.1.4.1.2636.3.1.13.1.11.9.1.0.0|Routing Engine 1 Buffer (%)
3|GET|.1.3.6.1.4.1.2636.3.1.13.1.11.7.4.0.0|FPC Buffer (%)

<...>

```

The leftmost ID must be unique.

> Graph generation only works for `GET` methods which return `integer` values.

All data collected by the poller is stored in TXT files named `DB_IDX_<ID>.POLLDB`, 
where `<ID>` is the same ID used on the `DB_CPU_MEM_WITH_IDX.DAT`.

> When initiating a new data collection, remember to delete the files `DB_IDX_*.POLLDB`.

- Update the router IP and the SNMP community variables:

```
my $router = "10.1.1.1";
my $community = "public";
```

- Run the poller

By default, the poller runs every 30 seconds. If required, change the polling interval at the end of the infinite loop.

```
sleep(30);
```

To run the poller, issue the following command:

```
./poller.pl DB_CPU_MEM_WITH_IDX.DAT
```

Once you finish your tests, press `Ctrl-C` to stop the poller.

> You need at least 10 cycles to be able to generate some graphs.

- Generate the graphs

```
./generate_graphs.sh
```

All graphs will be stored in `<poller_DIR>/graphs`.
