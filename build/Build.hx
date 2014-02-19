import sys.FileSystem;
import sys.io.File;

class Build
{
   public static function main()
   {
      var args = Sys.args();
      /*
      var path = "";
      if (args.length>0)
      {
         path = trimSlash(args.pop());
         if (!FileSystem.exists(path) || !FileSystem.isDirectory(path))
            path="";
      }

      if (path=="")
      {
         Sys.println("Usage: haxelib run waxe-works [options]");
         Sys.exit(0);
      }
      */

      var haxeExtra = new Array<String>();
      for(arg in args)
         haxeExtra.push(arg);

      var root = trimSlash(Sys.getCwd());
      var extract = root + "/wxWidgets";
      if (!FileSystem.exists(extract + "/extracted"))
      {
         Sys.println("Extracting...");
         Sys.command("tar", ["xvzf", "src/wxWidgets-20140212.tgz"]);
         File.saveContent("wxWidgets/extracted", "ok\n" );
         Sys.println("extracted ok");
      }
      else
      {
         Sys.println("already extracted");
      }
      Sys.setCwd(extract);

      Sys.println("Setup...");
      File.copy("../Build.xml", "Build.xml");

      copyRecurse("../setup", "include/wx");

      Sys.println("Build...");
      Sys.command("haxelib", ["run", "hxcpp", "Build.xml"].concat(haxeExtra) );

      Sys.setCwd(root);
      Sys.println("Headers...");
      mkdir("../include");
      copyRecurse("wxWidgets/include/wx", "../include/wx");
      copyRecurse("setup", "../include/wx");
      Sys.println("Done.");
   }

   public static function trimSlash(path:String)
   {
      while(path.substr(-1)=="/" || path.substr(-1)=="\\")
         path = path.substr(0,path.length-1);
      return path;
   }

   static function copyRecurse(from:String, to:String)
   {
      mkdir(to);
      for(file in FileSystem.readDirectory(from))
      {
         if (file.substr(0,1)!=".")
         {
            var path = from + "/" + file;
            if (FileSystem.isDirectory(path))
            {
                copyRecurse(path, to+"/"+file);
            }
            else
               copyIfDifferent(path,to+"/"+file);
         }
      }
   }

   static function mkdir(dir:String)
   {
      try
      {
        if (!FileSystem.exists(dir))
           FileSystem.createDirectory(dir);
      }
      catch(e:Dynamic)
      {
         Sys.println("Could not create "+ dir);
         Sys.exit(0);
      }
   }

   static function copyIfDifferent(from:String, to:String)
   {
      if (FileSystem.exists(to))
      {
         var fromData = File.getContent(from);
         var toData = File.getContent(to);
         if (from==to)
            return;
      }

      File.copy(from,to);
   }
}
