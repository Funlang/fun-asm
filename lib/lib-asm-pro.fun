
########################################
# lib-asm-pro
########################################
#  Copyright (c) 2017, funlang.org
########################################
use 'lib-asm.fun';

Assembly = AssemblyPro;
class AssemblyPro = AssemblyBase()
  fun Compile(c)
    if c =~ /^#!asm\b/ then
      use ':asm-list.log' as all;
      var asms = all.getJson();
      c = c.replace(/^#!asm\b/, '')
           .replace(/^\s*+(\w[^;\r\n]+[^;\s])\s*(;.*)?$/gm, (m){
        var a = m.@(1).replace(/\s++(?=[>)\]+*:,])|(?<=[<(\[+*:-])\s++/g, '')
                      .replace(/(?<=,)(?=\S)/, ' ')
                      .replace(/(?<=\s)\s++|\s++$/g, '');
        var asm = a;
        if asms[a] = nil then
          // function names in fun
          asm = asm.replace(/<(\w++)>/g, (n){
            var fn = names[n.@(1)];
            if fn <> nil then
              try      //[fun1: [fn: fn1, type: 'i:i', object: this], ...]
                result = int2hex(fn.fn.@toCallback(fn.object, fn.type, true));
              except   //[fun1:  fn1.@toCallback(this, 'i:i', true) , ...]
                result = int2hex(fn);
              end try;
            else
              raise '%s not found.'.format(n.@(1));
            end if;
          });
          // numbers
          a = asm.replace(/[-+]?(?<!\*)\$?\b([0-9A-F]++\b)/g, (n){
            var j = n.@(1).length();
            result = '%$j'.eval();
          });
        end if;
        if asms[a] = nil then
          raise '$a not found.'.eval();
        else
          result = asms[a];
          // numbers
          if result =~ /%/ then
            var r = result;
            asm.replace(/[-+]?(?<!\*)(\$)?\b([0-9A-F]++\b)/g, (n){
              r = r.replace(/%(\d)/, (o){
                var h = n.@(2);
                if n.@@() =~ /^-/ then
                  // todo
                end if;
                if n.@(1) = '$' then
                  if h.length() = 8 then
                    h = h.substr(6, 2) & h.substr(4, 2) & h.substr(2, 2) & h.substr(0, 2);
                  elsif h.length() = 4 then
                    h = h.substr(2, 2) & h.substr(0, 2);
                  end if;
                end if;
                result = h;
              });
            });
            result = r;
          end if;
        end if;
      }).replace(/\W++/g, '');
      return c;
    else
      return base.Compile(c);
    end if;
  end fun;
end class;
