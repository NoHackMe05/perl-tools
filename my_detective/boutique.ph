sub check_boutique {
        local ($content) = @_;

        if ($content =~ /href=\"?[^>\n]+shopping_cart\.php/i) {
                return 1;
	} elsif ($content =~ /href=\"?[^>\n]+page.shop\.cart/i) {
                return 1;
	} elsif ($content =~ /href=\"?[^>\n]+\/basket\/basket\.asp/i) {
                return 1;
	} elsif ($content =~ /href=\"?[0-9a-z\-_]*panier[0-9a-z\-_]*\.asp/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/[0-9a-z\-_]*panier[0-9a-z\-_]*\.asp/i) {
                return 1;
	} elsif ($content =~ /href=\"?[0-9a-z\-_]*panier[0-9a-z\-_]*\.php/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/[0-9a-z\-_]*panier[0-9a-z\-_]*\.php/i) {
                return 1;
        } elsif ($content =~ /href=\"?[0-9a-z\-_]*panier[0-9a-z\-_]*\.html/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/[0-9a-z\-_]*panier[0-9a-z\-_]*\.html/i) {
                return 1;
 	} elsif ($content =~ /href=\"?[a-z0-9\-]+[\/\-]+panier\.asp/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/[a-z0-9\-]+[\/\-]+panier\.asp/i) {
                return 1;
        } elsif ($content =~ /href=\"?panier\/panier[\._]/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/panier\/panier[\._]/i) {
                return 1;
        } elsif ($content =~ /href=\"?viewcart\./i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/viewcart\./i) {
                return 1;
        } elsif ($content =~ /href=\"?account\/basket/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/account\/basket/i) {
                return 1;
        } elsif ($content =~ /href=\"?cart\/view\.html/i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/cart\/view\.html/i) {
                return 1;
	} elsif ($content =~ /href=\"?[^>\n]*Shopping_Basket\//i) {
                return 1;
	} elsif ($content =~ /href=\"?[^>\n]+\/Panier\//i) {
                return 1;
	} elsif ($content =~ /href=\"?[^>\n]*\/caddie\./i) {
                return 1;
        } elsif ($content =~ /href=\"?[^>\n]+\/order\.php[^\.\?]/i) {
                return 1;
	} elsif ($content =~ /href=[\"\']http\:\/\/www\.jades\.fr[\"\'][^>]*>Solution de commerce en ligne<\/a>/i) {
                return 1;
	}

        return 0;
}

1;

