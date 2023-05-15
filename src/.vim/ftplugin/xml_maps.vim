if exists("b:did_xml_maps")
	finish
endif
let b:did_xml_maps = 1


"=====[ xmltidy ]===========================================================
Nmap ;p   [xmltidy the current buffer]   :%!xmlindent -i 2 <CR>
