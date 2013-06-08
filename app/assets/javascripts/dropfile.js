$(document).ready( function(){
  var fileFieldCount = 1;
  var attachFieldCount = 1; 
  
  var url = $('.dropzone').data('url')
    
  Dropzone.options.dropzone = {
    dictDefaultMessage: "<i class='icon-asset'></i> 添加附件",
    url: url,
    maxFilesize: 5, // MB
    maxThumbnailFilesize: 5 ,
  
    init: function() {
       this.on("processingfile", function(file) {
         this.options.paramName = "attachments[" + attachFieldCount + "][file]";
         attachFieldCount ++ ;       
       });
    
       this.on("addedfile", function(file) {     
         $('#button_submit').attr('disabled', true);
         var _this = this;          
         $(file.previewTemplate.querySelector(".error-mark")).on('click', function() {
            _this.removeFile(file); 
         });
       });  
          
       this.on("removedfile", function(file) { 
         var attachment_token = $(file.previewTemplate.querySelector('.details .fileid')).val();
         $.ajax({
           url: "/attachments/" + attachment_token,
           dataType: "script",
           type: "DELETE"
         })
       });     
     
       this.on("finished", function(file, responseText, e) {       
         file.previewTemplate.querySelector(".details").appendChild(Dropzone.createElement("<input  class=\"fileid\" type=\"hidden\"  name=\"attachments[" + fileFieldCount + "][token]\" value=\"" + responseText.attachment_token + "\" >"))
         fileFieldCount ++ ;               
       });
     
       this.on("complete", function() {
         if (this.filesQueue.length == 0 && this.filesProcessing.length == 0) {
           $('#button_submit').attr('disabled', false);
         }
       });
     
     }
  };
})  