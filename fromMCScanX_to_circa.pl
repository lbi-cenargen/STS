#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use IO::File;

#####open file######

 ##-- Get Option Long
    my ($in,$gff,$out);
    my $opts = GetOptions (    "in=s" => \$in,
                            "gff=s" => \$gff,
                            "out=s" => \$out
                          );
    exit() if( $in eq '' || $gff eq '' || $out eq ''); ## faire un usage à l'occasion

    my $fhr_in = new IO::File($in) or Carp::croak("ERROR INFILE - \"$in\" does not exist");
    my $fhr_gff = new IO::File($gff) or Carp::croak("ERROR INFILE - \"$gff\" does not exist");
    my $fhw_out = IO::File->new("> $out");
    my $out_stat = $out.".stat.txt";
    my $fhw_stat = IO::File->new("> $out_stat");

###### Testa primeiro argumento - Arquivo para separacao #######

###### Loop de leitura arquivo csv #######

my %h_gff;
while (my $line  = <$fhr_gff>)
{
   chomp $line;
   my @a_gff = split("\t",$line);
   $h_gff{$a_gff[1]} = $line;
}
#warn scalar(keys(%h_gff));
$fhr_gff->close();

my %h_verif;

while (my $line  = <$fhr_in>)
{
   chomp $line;

   my @a_gene = split(",",$line);
   for (my $x=0; $x<=$#a_gene; $x++){ $h_verif{$a_gene[$x]}++; }


#print Dumper(@a_gene);
   my $num_of_line = $#a_gene+1;
   if ($num_of_line > 1)
   {
    my $ct=0;
    for (my $j=1; $j<=$#a_gene;$j++)
    {
       my ($gene_line_ant,$gene_line_cur) = ('','');
       if (exists($h_gff{$a_gene[$j-1]}) && $h_gff{$a_gene[$j-1]} ne ''  ){ $gene_line_ant = $h_gff{$a_gene[$j-1]}; }
       if (exists($h_gff{$a_gene[$j]}) && $h_gff{$a_gene[$j]} ne ''  ){ $gene_line_cur = $h_gff{$a_gene[$j]}; }
       print $fhw_out join("\t",$gene_line_ant,$gene_line_cur) . "\n";
    }
      $ct++;
  }
}
$fhr_in->close();
$fhw_out->close();


foreach my $g (sort { $h_verif{$a}<=>$h_verif{$b}} keys %h_verif){ print $fhw_stat join("\t",$g,$h_verif{$g}) . "\n";}
$fhw_stat->close();
