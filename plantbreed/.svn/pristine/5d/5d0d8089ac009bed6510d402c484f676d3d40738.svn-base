
<!-- This is the project specific website template -->
<!-- It can be changed as liked or replaced by other content -->

<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='r-forge.r-project.org/themes/rforge/';

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en   ">

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><?php echo $group_name; ?></title>
	<link href="http://<?php echo $themeroot; ?>styles/estilo1.css" rel="stylesheet" type="text/css" />
  </head>

<body>

<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr><td>
<a href="http://r-forge.r-project.org/"><img src="http://<?php echo $themeroot; ?>/imagesrf/logo.png" border="0" alt="R-Forge Logo" /> </a> </td> </tr>
</table>


<!-- get project title  -->
<!-- own website starts here, the following may be changed as you like -->

<?php if ($handle=fopen('http://'.$domain.'/export/projtitl.php?group_name='.$group_name,'r')){
$contents = '';
while (!feof($handle)) {
	$contents .= fread($handle, 8192);
}
fclose($handle);
echo $contents; } ?>

<!-- end of project description -->
<hr><b>Description:</b>
</p>
</br>
<p>One of the main reasons for developing this package is that develop functions that are interest to plant breeders and geneticists.</p>
</br>
 Your feedback and suggestions are welcome.
</br></br>

<ul>
  <ul>
    <ul>
</br> The R-package <tt>plantbreeding</tt> collection of functions for analysis of data and visualization of results from Plant Breeding and Genetics experiments. <br>
       <li> Functionalities </li> 
        <ul>
        <li> Data analysis </li>
          <ul>  
          <li> Planning and Analysis of Plant breeding specialized designs </li>
		  <li> Estimation of variance components, heritability, and genetic correlation  </li>
		  <li> Stability and genotype x environment interaction analysis </li>
		  <li> Diversity and variability  analysis </li>
		  <li>  Selection and Selection index </li>
		  <li> Molecular breeding tools: Linkage, QTL mapping, association mapping </li>
		  </ul>
		<li> Data visualization </li>
		  </ul>
		 <li> Different functions to plot high quality graphics include both conventional and molecular breeding or genomewide graphics </li>. 
          </ul>
		  
 <hr><b> Licensing and WARRANTY </b>		  
  <li>The package comes with ABSOLUTELY NO WARRANTY; for details
see <a href="http://www.gnu.org/copyleft/gpl.html">http://www.gnu.org/copyleft/gpl.html</a>
(GPL). </li>
 </ul>
  </ul>
<hr><b>Installation and Download:</b>
<blockquote>

To install the latest development version of package <tt>plantbreeding</tt> from R-Forge (if you are running a recent R version), use<br>
<br>
<div style="text-align: center;"> <tt>install.packages("plantbreeding",repos="http://r-forge.r-project.org")</tt></div>
<br>
<blockquote>

<hr><b> R package dependencies </b>
<blockquote>

The plantbreeding depends upon lme4,  lattice and ggplot2 R packages. These packages are found for free installation from Comprehensive R Archive Network (CRAN) for free. The packages need to be installed for plantbreeding to work for specific functions
<br>
<blockquote>


<hr><b>Developer / Maintainer:</b>
<blockquote>
<p> The package is developed and maintained by Umesh Rosyara, Michigan State University, East Lansing.The bugs and suggestions can be mailed to the developer rosyara_at_dot_edu.</p>
</br>  
  </blockquote>



<p> The <strong>project summary page</strong> you can find <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><strong>here</strong></a>. </p>

<img style="width: 800px; height: 800px;" alt="snap shots of plantbreeding graphs" src="http://r-forge.r-project.org/scm/viewvc.php/*checkout*/www/figuresnapshot.png?root=plantbreeding"><br>
<br>

</body>
</html>
