#!/bin/sh
#
#
#

mkdir /mnt/RAID1/wikisearch/document
cd /mnt/RAID1/wikisearch/document

for lettre1 in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
        for lettre2 in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for lettre3 in a b c d e f g h i j k l m n o p q r s t u v w x y z
                do
                        echo $lettre1$lettre2$lettre3

                        mkdir $lettre1$lettre2$lettre3
                done
        done
done

mkdir /mnt/RAID1/wikisearch/recherche
cd /mnt/RAID1/wikisearch/recherche

for lettre1 in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
        for lettre2 in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for lettre3 in a b c d e f g h i j k l m n o p q r s t u v w x y z
                do
                        echo $lettre1$lettre2$lettre3

                        mkdir $lettre1$lettre2$lettre3
                done
        done
done

mkdir /mnt/RAID1/wikisearch/portail
cd /mnt/RAID1/wikisearch/portail

for lettre1 in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
        for lettre2 in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for lettre3 in a b c d e f g h i j k l m n o p q r s t u v w x y z
                do
                        echo $lettre1$lettre2$lettre3

                        mkdir $lettre1$lettre2$lettre3
                done
        done
done

mkdir /mnt/RAID1/wikisearch/livres
cd /mnt/RAID1/wikisearch/livres

for lettre1 in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
        for lettre2 in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for lettre3 in a b c d e f g h i j k l m n o p q r s t u v w x y z
                do
                        echo $lettre1$lettre2$lettre3

                        mkdir $lettre1$lettre2$lettre3
                done
        done
done

mkdir /mnt/RAID1/wikisearch/rech_livres
cd /mnt/RAID1/wikisearch/rech_livres

for lettre1 in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
        for lettre2 in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for lettre3 in a b c d e f g h i j k l m n o p q r s t u v w x y z
                do
                        echo $lettre1$lettre2$lettre3

                        mkdir $lettre1$lettre2$lettre3
                done
        done
done

cd /mnt/RAID1/wikisearch

exit

