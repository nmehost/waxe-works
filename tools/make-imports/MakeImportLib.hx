import sys.io.File;
import haxe.io.Path;

class MakeImportLib
{
   public static function main( )
   {
      var args = Sys.args();
      if (args.length>0)
         process(args);
      else
      {
         for(lib in [
            "gtk-x11-2.0",
            "glib-2.0",
            "gobject-2.0",
            "gdk-x11-2.0",
            "gdk_pixbuf-2.0",
            "cairo",
            "pango-1.0",
            "pangocairo-1.0",
            "gthread-2.0",
            "GL",
            "Xxf86vm",
            "Xext",
            "SM",
            "dl",
            "X11" ])
          {
             process(["/usr/lib/x86_64-linux-gnu/lib"+lib+".so", "export32"]);
             process(["/usr/lib/x86_64-linux-gnu/lib"+lib+".so", "export64", "-64" ]);
          }
        }
   }

   public static function process(args:Array<String>)
   {
      var name:String = null;
      var dir:String = null;
      var bits:Int = 32;
      var badArgs = false;

      for(arg in args)
      {
         if (arg.substr(0,1)=="-")
         {
            if (arg=="-64")
               bits=64;
            else
               badArgs = true;
         }
         else if (name==null)
             name = arg;
         else if (dir==null)
             dir = arg;
         else
             badArgs = true;
      }

      if (badArgs || name==null || dir==null)
      {
        Sys.println("Usage mkimport so_name scratch_dir [-64]");
        return;
      }

      var proc = new sys.io.Process("nm", ["-D", "--defined-only", name]);
      var out = proc.stdout;
      var functions = new Array<String>();
      var data = new Array<String>();
      try
      {
         while(true)
         {
            var line = out.readLine();
            var parts = line.split(" ");
            if (parts[1]=="R")
               data.push(parts[2]);
            else if (parts[1]!="T")
               Sys.println("Unknown line format " + line);
            else if (parts[2]=="_init" || parts[2]=="_fini")
               Sys.println("Ignore " + parts[2]);
            else
               functions.push(parts[2]);
         }
      }
      catch(e:Dynamic){ }
      if (functions.length==0 && data.length==0)
        throw "Could not find symbols in " + name;

      var baseName = Path.withoutDirectory(name);

      var cFile = dir + "/" + baseName + ".c";
      var lines = new Array<String>();
      for(line in functions)
         lines.push('void $line(){};');
      for(datum in data)
         lines.push('const int $datum = 123;');
      File.saveContent(cFile, lines.join("\n"));
      var bitArg = bits==64 ? "-m64" : "-m32";

      var libName = Path.withoutDirectory(name);

      command("gcc", [cFile, "-shared", "-fpic", "-fPIC", bitArg, "-o" + dir + "/" + libName ]);

   }

   static function command(inExe:String, inArgs:Array<String>)
   {
      Sys.println(inExe + " " + inArgs.join(" ") );
      Sys.command(inExe, inArgs);
   }
}


