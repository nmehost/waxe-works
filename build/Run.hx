import sys.FileSystem;
import sys.io.File;

class Run
{
   public static function main()
   {
      var args = Sys.args();
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

      var haxeExtra = new Array<String>();
      for(arg in args)
         haxeExtra.push(arg);

      var root = trimSlash(Sys.getCwd());
      var extract = root + "/build/extract";
      if (!FileSystem.exists(extract + "/extracted"))
      {
         mkdir(extract);
         Sys.setCwd(extract);

         Sys.println("Extracting...");
         Sys.command("tar", ["xvzf", "../src/wxWidgets-3.0.0.tgz"]);
         File.saveContent("extracted", "ok\n" );
         Sys.println("extracted ok");
      }
      else
      {
         Sys.println("already extracted");
         Sys.setCwd(extract);
      }

      Sys.println("Setup...");
      File.copy("../wxWidgetBuild.xml", "wxWidgetBuild.xml");

      copyRecurse("../setup", "include/wx");

      Sys.println("Build...");
      Sys.command("haxelib", ["run", "hxcpp", "wxWidgetBuild.xml"].concat(haxeExtra) );

      Sys.println("Headers...");
      Sys.setCwd( root );
      mkdir("include");
      copyRecurse("build/extract/include/wx", "include/wx");
      copyRecurse("build/setup", "include/wx");
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
