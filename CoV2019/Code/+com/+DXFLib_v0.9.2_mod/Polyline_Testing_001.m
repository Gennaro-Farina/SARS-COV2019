
FileDXF_drw = dxf_open('Caso6A.dxf')

PointX_arr = [0 1 3]'
PointY_arr = [0 1 10]'
PointZ_arr = [0 0 0]'

FileDXF_drw = dxf_set(FileDXF_drw,'Color',[1 0 0],'Layer','Pippo')
FileDXF_drw = dxf_polyline(FileDXF_drw,PointX_arr,PointY_arr,PointZ_arr)

dxf_close(FileDXF_drw)


fclose('all')