#find differences between 2 TD

#!/usr/bin/perl -w
use strict;
use warnings;
use Spreadsheet::ParseExcel;
use List::Compare;
use Data::Dumper;
use Text::Compare;
use Digest::MD5 qw(md5_hex);

#code usage
if (@ARGV < 1){
  print "\n\tusage: perl code.pl <Old_filename.xls> <New_filename.xls> > output file\n";
}
 
#Load the first file
my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse($ARGV[0]);
#load the second file
my $parser1   = Spreadsheet::ParseExcel->new();
my $workbook1 = $parser1->parse($ARGV[1]);
 
if ( !defined $workbook || !defined $workbook1 ) {
    die $parser->error(), ".\n";
}

#tab that will store the values of the differents colomns from each file
#the string similarity will be done on these tab
my (@name, @name1); 
my (@id, @id1);
my (%line, %line1);
#Load the values of the first file
for my $worksheet ( $workbook->worksheets() ) {
    #get file size
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
    $col_min = 14;
    for my $row ( $row_min .. $row_max ) {
        for my $col ( $col_min .. $col_max ) {
            my $colId = 10; ### get id
            my $colLang = 4; ### get language. Impotant if multilanguage
            my $cell = $worksheet->get_cell( $row, $col);
            next unless $cell; ### if cell is not empty
            
            push(@name, lc($cell->value()));

            next unless $worksheet->get_cell( $row, $colId );   ####if id exists, for a given id in a given lang, rewrite row 
            next unless $worksheet->get_cell( $row, $colLang )->value()=~/en/i;
            $line{$worksheet->get_cell( $row, $colId )->value().lc($worksheet->get_cell( $row, $colLang )->value())}.=$cell->value();
            $line{$worksheet->get_cell( $row, $colId )->value().lc($worksheet->get_cell( $row, $colLang )->value())}.=";";
        }
    }
}
    #Load the values of the second file
for my $worksheet ( $workbook1->worksheets() ) {
 
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
    $col_min = 14;
    for my $row ( $row_min .. $row_max ) {
        for my $col ( $col_min .. $col_max ) {
            my $colId1 = 10; ### get id
            my $colLang1 = 4; ### get language. Impotant if multilanguage
            my $cell = $worksheet->get_cell( $row, $col );
            next unless $cell;   ### if cell is not empty
            
            push(@name1, lc($cell->value()));

            next unless $worksheet->get_cell( $row, $colId1 );    ####if id exists, for a given id in a given lang, rewrite row 
            next unless $worksheet->get_cell( $row, $colLang1 )->value()=/en/i;
            $line1{$worksheet->get_cell( $row, $colId1 )->value().lc($worksheet->get_cell( $row, $colLang1 )->value())}.=$cell->value();
            $line1{$worksheet->get_cell( $row, $colId1 )->value().lc($worksheet->get_cell( $row, $colLang1 )->value())}.=";";
           
        }
    }
}
   
#print Dumper \@name, \@name1;
################# Polapgen file VS ICarda. 
################# IMPORTANT: the first file is not the updated version of the second file. For this look at next part below

    # my @intersection;
    # my $tc3 = new Text::Compare(memoize => 1, strip_html => 0);
    # foreach my $e (@name){
    #     $e=~s/[(,].+//;
    #     foreach my $e1 (@name1){
    #          $e1=~s/[(,].+//;
    #         #print "$e = $e1\n";
            

    #         $tc3->first($e);
    #         $tc3->second($e1);

    #          if($tc3->similarity>0.55){
    #             push (@intersection, "$e = $e1");
    #         }
    #     }
        
    # }    
        
    # print Dumper \@intersection;

################## Look for updated lines between two files    
    my @line = keys(%line);
    my @line1 = keys(%line1);

    ### compare list of trait ids
    my $lc = List::Compare->new(\@line, \@line1);
    ### Get those items which appear at least once in both lists (their intersection).
    my @intersection = $lc->get_intersection;
    ### Get those items which appear (at least once) only in the first list.
    my @Lonly = $lc->get_unique;
    ### Get those items which appear (at least once) only in the second list.
    my @Ronly = $lc->get_complement;

    #print "Lonly ",@Lonly,"\n";
    #print "Ronly ",@Ronly,"\n";

    print "Data deleted from old file : \n";
    foreach my $Lonly (@Lonly){
        print $line{$Lonly};
        print "\n";
    }
    print "\n########################################################\n";

    print "Data added to old file : \n";
    foreach my $Ronly (@Ronly){
        print $line1{$Ronly};
        print "\n";
    }

    print "\n########################################################\n";
    # print Dumper \@intersection;
    print "Data modified in new file compared to old one: \n";
    foreach my $intersection (@intersection){
        # print "$intersection\n";
        # print "$line{$intersection}\n";
        # print "$line1{$intersection}\n";
        
        # my $digest = md5_hex($line{$intersection});
        # my $digest1 = md5_hex($line1{$intersection});
        # print $digest."\n";
        # print $digest1."\n";

        if($line{$intersection} ne $line1{$intersection}){
            print $line{$intersection};
            print "\n";
            print $line1{$intersection};
            print "\n";

            print "\n";
            print "\n";
        }
        

    }


