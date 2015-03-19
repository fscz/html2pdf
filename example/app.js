var html = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xmlns:fr="http://factisresearch.com/ns/fr"><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-15"><title>Home - factis research GmbH</title><body><p>combines detailed domain knowledge with technical expertise and profound knowledge in all areas of software engineering. The focus of our technical expertise lies on programming languages, operating systems, networks, and databases. Further, we turn theory into practice by applying latest results of computer science research to our daily work. Our development process is highly influenced by the agile movement and the scrum methodology.</p>';

var imageData = Titanium.Filesystem.getFile('Default.png').read();
var iv = Ti.UI.createImageView({
  image: imageData
      });
var image = iv.toImage();
var imageB64 = Ti.Utils.base64encode(image);

html += '<p><img src="data:image/png;base64,'+imageB64+'"></p></body></html>';

// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var button = Ti.UI.createButton({
  title:'Gen/attach PDF',
  height:'auto',
  width:'auto'
});
win.add(button);


// TODO: write your module tests here
var html2pdf = require('com.factisresearch.html2pdf');
Ti.API.info("module is => " + html2pdf);


html2pdf.addEventListener('pdfready', function(e) {
    var pdfFile = Ti.Filesystem.getFile(e.pdf);
    var emailDialog = Ti.UI.createEmailDialog();
    emailDialog.addAttachment(pdfFile);
    emailDialog.open();
});

button.addEventListener('click', function(e) {
    html2pdf.setHtmlString([html, "foo.pdf"]); // second argument is for filename
                                                                      // note that you should delete this
                                                                      // when you are done
});


win.open();
