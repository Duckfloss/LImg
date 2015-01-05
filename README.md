#Lee's Scripts
This is a collection of perl scripts I hacked together to make my life easier.
I use them to automate some portions of transmitting products from RPro to the website:
http://LeesAdventureSports.com

The files are as follows:
* **batchImages.pl** - grabs all the image files in a directory, squares them, and parses them out into different sizes for publication on the website: 100px, 350px, 1050px
* **colors.pl** - actually just parses a CSV a removes duplicate indexes. I used it to parse the North Face's color codes
* **TNF_CSV2File.pl** - parses the North Face's product catalogs and spits out description text for the website.
