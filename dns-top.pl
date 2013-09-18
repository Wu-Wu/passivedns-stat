#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.12';
use Data::Dump ();
use List::MoreUtils ();
use Getopt::Long;
use Sys::Hostname;

my $VERSION = '0.001';

unless ($ARGV[0]) {
    say "Usage: $0 [-l limit] -a ip1,ip2 logfile1 [logfile2] ...";
    exit;
}

my $LIMIT   = 20; # количество выводимых строк
my $IPSTR   = ''; # строка с адресами сервера имён
my %IPS     = (); # адреса сервера имён
my $HELP    = 0;

GetOptions(
    'help|h'    => \$HELP,
    'limit|l=i' => \$LIMIT,
    'ips|a=s'   => \$IPSTR,
);

%IPS = host_ips($IPSTR);

unless (scalar(keys %IPS)) {
    say 'IP Address(es) required. User "-a" option';
    exit;
}

my $ipaddr_stat = {};
my $domain_stat = {};
my $totals = 0;

say 'Statistics for nameserver: ' . hostname();
say 'Nameserver IPs: ' . join(', ' => keys %IPS);

while (my $line = <>) {
    chomp($line);
    my ($ts, $client, $ns, $class, $query, $type, $answer, $ttl, $hits) = split /\|\|/, $line;

    next unless $class eq 'IN';
    next unless exists $IPS{$ns}; # пропуск записей, где ip не принадлежат текущему серверу

    $ipaddr_stat->{$client} += $hits;

    $domain_stat->{ to_domain(lc $query) } += $hits;
    $totals += $hits;
}

my @by_domains = arrange_stat($domain_stat, $LIMIT);
my @by_ipaddrs = arrange_stat($ipaddr_stat, $LIMIT);

display_top('domain name', [ @by_domains ], $totals, $LIMIT);
display_top('ip address', [ @by_ipaddrs ], $totals, $LIMIT);

# преобразование запроса в доменное имя
sub to_domain {
    my ($query) = @_;

    my @domain;

    my ($top, $middle, $rest) = reverse split /\./, $query;

    push @domain, ($top, $middle);  # топ и мидл всегда

    my $rx = qr/
        ^(com | net | org | gov | biz)$ |           # popular extensions no.1: .COM.RU, .NET.UA
        ^(info | edu | mil)$ |                      # popular extensions no.2: .MIL.IN
        ^(ind | ebiz | game | firm)$ |              # not so popular extensions no.1: .FIRM.IN
        ^(pro | nom | idv | gen | med | jpn)$ |     # not so popular extensions no.2: .GEN.IN
        ^(msk | spb | kiev)$ |                      # geo extensions: .MSK.RU, .SPB.RU, .KIEV.UA
        ^a[cdefgilmoqrstuwxz]$ |                    # letter A: ISO 3166-1
        ^b[abdefghijmnorstwyz]$ |                   # letter B: ISO 3166-1
        ^c[acdfghiklmnoruvwxyz]$ |                  # letter C: ISO 3166-1
        ^d[ejkmoz]$ |                               # letter D: ISO 3166-1
        ^e[cegrstu]$ |                              # letter E: ISO 3166-1
        ^f[ijkmor]$ |                               # letter F: ISO 3166-1
        ^g[adefghilmnpqrstuwy]$ |                   # letter G: ISO 3166-1
        ^h[kmnrtu]$ |                               # letter H: ISO 3166-1
        ^i[delmnoqrst]$ |                           # letter I: ISO 3166-1
        ^j[emop]$ |                                 # letter J: ISO 3166-1
        ^k[eghimnprwyz]$ |                          # letter K: ISO 3166-1
        ^l[abcikrstuvy]$ |                          # letter L: ISO 3166-1
        ^m[acdeghklmnopqrstuvwxyz]$ |               # letter M: ISO 3166-1
        ^n[acefgilopruz]$ |                         # letter N: ISO 3166-1
        ^o[m]$ |                                    # letter O: ISO 3166-1
        ^p[aefghklmnrstwy]$ |                       # letter P: ISO 3166-1
        ^q[a]$ |                                    # letter Q: ISO 3166-1
        ^r[eosuw]$ |                                # letter R: ISO 3166-1
        ^s[abcdeghiklmnorstuvxyz]$ |                # letter S: ISO 3166-1
        ^t[cdfghjklmnortvwz]$ |                     # letter T: ISO 3166-1
        ^u[agksyz]$ |                               # letter U: ISO 3166-1
        ^v[aceginu]$ |                              # letter V: ISO 3166-1
        ^w[fs]$ |                                   # letter W: ISO 3166-1
        ^y[et]$ |                                   # letter Y: ISO 3166-1
        ^z[amw]$                                    # letter Z: ISO 3166-1
    /x;

    # проверка неоходимости учёта третьего уровня
    if ($middle =~ /$rx/) {
        # забираем из оставшейся части домен третьего уровня (если есть что забирать)
        if ($rest) {
            my ($third, undef) = split /\./, $rest, 2;
            push @domain, $third;
        }
    }

    '.' . join '.' => reverse @domain;
}

# TOP
sub arrange_stat {
    my ($stat, $limit) = @_;

    $limit //= 20; # лимит по умолчанию

    my @sorted = sort { $stat->{$b} <=> $stat->{$a} } keys %$stat;

    # ограничиваем указанным лимитом
    @sorted = splice @sorted, 0, $limit if scalar @sorted > $limit;

    my @vals = @{$stat}{@sorted};

    List::MoreUtils::zip @sorted, @vals;
}

# ip адреса сервера имён
sub host_ips {
    my ($ips) = @_;
    map { $_ => 1 } split /[,\s]+/ => $ips;
}

# вывод таблицы статистики
sub display_top {
    my ($name, $stat, $totals, $limit) = @_;

    # форматы для вывода данных
    my $formats = {
        head => '%-30s %6s %s',
        body => '%-30s %6d %.2f',
    };

    my $top_items = 0;

    # показывать статистику "остальные домены"
    my $show_leftovers = scalar(@$stat) < 2*$limit ? 0 : 1;

    say '';
    say sprintf($formats->{head} => uc($name), 'HITS', '%%');
    while (my ($item, $hits) = splice @$stat, 0, 2) {
        say sprintf($formats->{body} => $item, $hits, $hits/$totals*100);
        $top_items += $hits;
    }

    if ($show_leftovers) {
        say sprintf($formats->{body} => 'LEFTOVERS SUMMARY', $totals-$top_items, ($totals-$top_items)/$totals*100);
    }
}

1;
__END__
