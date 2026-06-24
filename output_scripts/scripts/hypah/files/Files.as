package hypah.files
{
   import flash.errors.IOError;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   
   public class Files
   {
       
      
      public function Files()
      {
         super();
      }
      
      public static function readLocalFile(param1:String) : ByteArray
      {
         var fileStream:FileStream = null;
         var fileContent:ByteArray = null;
         var filePath:String = param1;
         var file:File = File.applicationDirectory.resolvePath(filePath);
         if(file.exists)
         {
            try
            {
               fileStream = new FileStream();
               fileStream.open(file,FileMode.READ);
               fileContent = new ByteArray();
               fileStream.readBytes(fileContent);
               fileStream.close();
               return fileContent;
            }
            catch(error:IOError)
            {
               trace("Failed to read the file: " + error.message);
            }
         }
         else
         {
            trace("File does not exist: " + file.nativePath);
         }
         trace("wtf");
         return null;
      }
      
      public static function overwriteFileFromAppDirectory(param1:String, param2:ByteArray) : void
      {
         var fileStream:FileStream = null;
         var filePath:String = param1;
         var ba:ByteArray = param2;
         var file:File = File.applicationDirectory.resolvePath(filePath);
         trace(file.nativePath);
         try
         {
            fileStream = new FileStream();
            fileStream.open(file,FileMode.WRITE);
            fileStream.writeBytes(ba);
            fileStream.close();
            trace("File overwritten successfully.");
         }
         catch(error:IOError)
         {
            trace("Error writing to file: " + error.message);
         }
      }
      
      public static function overwriteFileFromDesktopDirectory(param1:String, param2:ByteArray) : void
      {
         var fileStream:FileStream = null;
         var filePath:String = param1;
         var ba:ByteArray = param2;
         var file:File = File.desktopDirectory.resolvePath(filePath);
         trace(file.nativePath);
         try
         {
            fileStream = new FileStream();
            fileStream.open(file,FileMode.WRITE);
            fileStream.writeBytes(ba);
            fileStream.close();
            trace("File overwritten successfully.");
         }
         catch(error:IOError)
         {
            trace("Error writing to file: " + error.message);
         }
      }
   }
}
