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

```
Statistics for nameserver: svo
Nameserver IPs: 10.1.13.13

DOMAIN NAME                      HITS %%
.google.com                       384 25.67
.livejournal.com                  222 14.84
.gigaset.net                      178 11.90
.last.fm                           62 4.14
.googleusercontent.com             42 2.81
.akamai.net                        38 2.54
.dropbox.com                       30 2.01
.reg.ru                            28 1.87
.cdngc.net                         24 1.60
.akamaiedge.net                    24 1.60
.edgekey.net                       24 1.60
.yahoodns.net                      18 1.20
.amazonaws.com                     18 1.20
.twitter.com                       16 1.07
.cloudfront.net                    16 1.07
.youtube.com                       14 0.94
.verisign.net                      14 0.94
.yahoo.com                         14 0.94
.footprint.net                     12 0.80
.edgesuite.net                     12 0.80
LEFTOVERS SUMMARY                 306 20.45

IP ADDRESS                       HITS %%
10.1.13.110                      1318 88.10
10.1.13.9                         178 11.90
```

### опции dns-top.pl

#### --help | -h
вывод справки

#### --ips | -a
список адресов сервера имён, для которого требуется статистика. в одну строку. разделитель: пробел и (или) запятая.

#### --limit | -l
лимит выводимых записей. по-умолчанию - 20 записей (TOP20).

