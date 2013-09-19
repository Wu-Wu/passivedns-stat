passivedns-stat
===============

> скрипты статистики на основе логов passivedns

## Исходный файл лога

```
1379325820.764062||10.1.13.110||10.1.13.13||IN||r1---sn-n8v7lne6.c.youtube.com.||CNAME||r1.sn-n8v7lne6.c.youtube.com.||1800||1
1379325820.764062||10.1.13.110||10.1.13.13||IN||r1.sn-n8v7lne6.c.youtube.com.||A||74.125.110.48||1800||1
1379325821.026914||10.1.13.110||10.1.13.13||IN||r9---svo02s15.c.youtube.com.||CNAME||r9.svo02s15.c.youtube.com.||1800||1
1379325821.026914||10.1.13.110||10.1.13.13||IN||r9.svo02s15.c.youtube.com.||A||74.125.110.56||1800||1
1379325873.727124||10.1.13.110||10.1.13.13||IN||collector.githubapp.com.||A||54.242.11.189||30||1
1379325892.319234||10.1.13.110||10.1.13.13||IN||yandex.st.||A||93.158.134.215||86400||1
1379325892.319234||10.1.13.110||10.1.13.13||IN||yandex.st.||A||213.180.204.215||86400||1
...
```

## dns-top.pl: TOP доменов и адресов клиентов

```shell
$ ./dns-top.pl -a 10.1.13.13 logs/pdns1.log logs/pdns2.log
```

будет выведени следующая статистика:

```
Statistics for nameserver: svo
Nameserver IPs: 10.1.13.13

DOMAIN NAME                      HITS %%
google.com                        192 25.67
livejournal.com                   111 14.84
gigaset.net                        89 11.90
last.fm                            31 4.14
googleusercontent.com              21 2.81
akamai.net                         19 2.54
dropbox.com                        15 2.01
reg.ru                             14 1.87
edgekey.net                        12 1.60
cdngc.net                          12 1.60
akamaiedge.net                     12 1.60
yahoodns.net                        9 1.20
amazonaws.com                       9 1.20
cloudfront.net                      8 1.07
twitter.com                         8 1.07
verisign.net                        7 0.94
yahoo.com                           7 0.94
youtube.com                         7 0.94
akadns.net                          6 0.80
footprint.net                       6 0.80
LEFTOVERS SUMMARY                 153 20.45

IP ADDRESS                       HITS %%
10.1.13.110                       659 88.10
10.1.13.9                          89 11.90
```

### опции dns-top.pl

#### --help | -h
вывод справки

#### --ips | -a
список адресов сервера имён, для которого требуется статистика. необходимая опция. в одну строку. разделитель: пробел и (или) запятая. например,
```shell
$ ./dns-top.pl -a "10.1.13.13,10.1.13.15,2001:1388:7a80::10" /path/to/passivedns.log
```

#### --limit | -l
лимит выводимых записей. по-умолчанию - 20 записей (TOP20). например,
```shell
$ ./dns-top.pl -l 10 -a 127.0.0.1 /path/to/passivedns.log
```
