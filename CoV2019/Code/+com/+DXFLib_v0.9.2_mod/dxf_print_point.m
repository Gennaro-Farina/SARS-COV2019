function dxf_print_point(FID,pointno,x,y,z)
%DXF_PRINT_POINT Dump entity properties.
%   Internal function: Not usable directly.
%
%   Copyright 2011 Grzegorz Kwiatek
%   $Revision: 1.0.0 $  $Date: 2011.08.25 $%
%   $BugFix: Gabriele Piantadosi $Date: 2019.02.08

try
  fprintf(FID.fid,'1%1d\n%1.16g\n2%1d\n%1.16g\n3%1d\n%1.16g\n',pointno,round(x,5),pointno,round(y,5),pointno,round(z,5));
catch exception
  if FID.fid >= 0
    fclose(FID.fid);
  end
  rethrow(exception);
end
