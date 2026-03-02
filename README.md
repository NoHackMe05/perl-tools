# Perl

## dmoz

Script permettant à l'époque de l'annuaire DMOZ de vérifier qu'un site était référencé dedans

## Fast Async DNS Resolver (IPv4/IPv6)

Ce projet est un outil de résolution DNS inverse (PTR) écrit en Perl. Il utilise une architecture orientée objet et asynchrone pour traiter des volumes massifs d'adresses IP sans saturer la mémoire vive.

### Caractéristiques
- **Dual-Stack** : Support natif de l'IPv4 et de l'IPv6 (`ip6.arpa`).
- **Asynchrone** : Basé sur `AnyEvent`, permet des centaines de requêtes simultanées.
- **Gestion de la mémoire** : Lecture en streaming (ligne à ligne) via les filehandles pour un usage RAM constant.
- **Fiabilité** : Gestion automatique des tentatives (*retries*) en cas de timeout UDP.
- **Propre** : Résultats valides sur `STDOUT`, erreurs horodatées dans `resolver_errors.log`.

### Lancer via un pipe

```bash
cat test/test_ips.txt | ./resolve.pl > resultats.csv
./resolve.pl < fast_ips.txt
```

### Benchmarks avec max_retries = 0
- **149 IPs** : ~1.01s
- **4556 IPs** : ~4.05s

### Benchmarks avec max_retries = 2
- **149 IPs** : ~3.01s
- **4556 IPs** : ~7.37s

## my_detective

Crawler permettant de parcourir les sites internet en Europe avec comme but de catégoriser les sites par pays et aussi suivant certaines thématiques : btp, écologie. Il était question également de récupérer les boutiques en ligne ainsi que les produits commencialisés. On récupère également les documents word, excel, pdf, ... Et enfin, on récupère les mentions légales (coordonnées des entreprises) => projet Utilisé par french-spider.com

## position

Utilisé dans des projets en rapport avec le SEO, permettait de récupérer les premières positions de moteur de recherche

## wikisearch

Récupération des informations de wikipédia pour créer un moteur de recherche qui était utilisé par french-spider.com => sur le site internet, lorsqu'on effectuait un double clic sur un mot, on avait un popup qui s'ouvrait avec la définition.