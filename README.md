# DNSResolver — Résolution DNS inverse massivement parallèle en Perl

Résolution PTR asynchrone haute performance, basée sur `AnyEvent::DNS`. Conçu pour traiter des volumes importants d'adresses IP (IPv4 et IPv6) via pipe STDIN, avec gestion des timeouts, des retries, et journalisation des erreurs.

---

## Prérequis

- **Perl** ≥ 5.16
- Modules CPAN :

| Module | Rôle |
|---|---|
| `Moo` | Système objet léger |
| `AnyEvent` | Boucle d'événements asynchrone |
| `AnyEvent::DNS` | Résolution DNS non-bloquante |
| `Net::IP` | Validation et normalisation des adresses IP |
| `Time::HiRes` | Mesure de temps précise |
| `namespace::clean` | Nettoyage de l'espace de noms |

Installation via CPAN :

```bash
cpanm Moo AnyEvent AnyEvent::DNS Net::IP Time::HiRes namespace::clean
```

---

## Structure du projet

```
.
├── DNSResolver.pm          # Module principal — moteur de résolution async
├── resolve.pl              # Script d'entrée — lecture STDIN, affichage CSV, logging
├── resolver_errors.log     # Généré à l'exécution (mode append)
└── test/
    ├── fast_ips.txt        # 4 556 IPs (IPv4 + IPv6) — test de charge
    └── test_ips.txt        # 149 IPs — test fonctionnel
```

---

## Utilisation

### Entrée standard (mode pipe)

```bash
cat test/test_ips.txt | perl resolve.pl
```

### Redirection de la sortie CSV

```bash
cat test/fast_ips.txt | perl resolve.pl > results.csv
```

### Avec filtrage des erreurs sur STDERR

```bash
cat test/fast_ips.txt | perl resolve.pl > results.csv 2>progress.log
```

---

## Format de sortie

### STDOUT — résolutions réussies (CSV)

```
1.2.3.4,host.example.com
2606:4700:4700::1111,one.one.one.one
```

Chaque ligne contient `IP,hostname`. Si une IP a plusieurs enregistrements PTR, ils sont séparés par des virgules dans la deuxième colonne.

### STDERR — progression (toutes les 1000 IPs)

```
Processed: 1000
Processed: 2000
...
Terminé ! 4556 IPs traitées en 12.43s (366.53 ips/s)
```

### `resolver_errors.log` — erreurs (mode append)

```
[Tue Mar 31 14:22:01 2026] ERROR: 10.0.0.1         -> [TIMEOUT_ERROR]
[Tue Mar 31 14:22:01 2026] ERROR: 192.0.2.5        -> [NXDOMAIN]
[Tue Mar 31 14:22:01 2026] ERROR: not_an_ip        -> [INVALID_IP_FORMAT]
```

---

## Codes d'état

| Code | Signification |
|---|---|
| `[NXDOMAIN]` | Pas d'enregistrement PTR pour cette IP |
| `[TIMEOUT_ERROR]` | Aucune réponse reçue après tous les essais |
| `[INVALID_IP_FORMAT]` | L'entrée n'est pas une adresse IP valide |

---

## Configuration (`resolve.pl`)

Les paramètres du résolveur sont instanciés dans `resolve.pl` :

```perl
my $resolver = DNSResolver->new(
    max_parallel => 1000,   # Nombre de requêtes simultanées
    max_retries  => 2,      # Tentatives supplémentaires en cas de timeout
    timeout      => 1,      # Délai par tentative (secondes)
    on_result    => sub { ... },
    on_finish    => sub { ... },
);
```

| Paramètre | Défaut dans DNSResolver.pm | Valeur dans resolve.pl | Description |
|---|---|---|---|
| `max_parallel` | 500 | 1000 | Requêtes DNS simultanées max |
| `timeout` | 2 | 1 | Timeout par tentative (s) |
| `max_retries` | 2 | 2 | Nombre de retries après timeout |

> **Note :** `max_outstanding` du résolveur global est automatiquement fixé à `max_parallel * 2` pour éviter le goulot d'étranglement par défaut d'AnyEvent::DNS (10 requêtes).

---

## Fonctionnement interne (`DNSResolver.pm`)

```
run_from_handle(fh)
      │
      ▼
 _process_next()  ◄─────────────────────────────────────┐
      │                                                   │
      │  (remplit jusqu'à max_parallel slots)             │
      ▼                                                   │
_resolve_with_retry(ip, attempt=0)                       │
      │                                                   │
      ├── AnyEvent::DNS::reverse_lookup  ──► on_result   │
      │         (succès ou NXDOMAIN)          _active--  ─┘
      │
      └── AnyEvent->timer (timeout)
                │
                ├── attempt < max_retries ──► retry (attempt+1)
                │
                └── sinon ──► on_result([TIMEOUT_ERROR])
                              _active--  ──► _process_next()
```

- EDNS0 activé (réponses UDP jusqu'à 4096 octets).
- La boucle `_cv->recv` / `_cv->send` bloque jusqu'à épuisement complet du fichier et de la file active.

---

## Tests

### Test fonctionnel (149 IPs)

```bash
cat test/test_ips.txt | perl resolve.pl
```

### Test de charge (4 556 IPs, IPv4 + IPv6)

```bash
cat test/fast_ips.txt | perl resolve.pl > /dev/null
```

Le résumé de performance est affiché sur STDERR en fin d'exécution.

---

## Licence

Projet interne — aucune licence open source définie.