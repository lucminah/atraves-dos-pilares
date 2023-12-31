GDPC                P
                                                                         \   res://.godot/exported/133200997/export-16ab7891c9ae011599b4d7a01161bbe7-node_obstaculo.scn   Q      7      t���qИ��6���b~    T   res://.godot/exported/133200997/export-7007da6367635e832fa0ed2dd817d63f-mundo.scn   �>      |      ���~�W#��/�X    X   res://.godot/exported/133200997/export-76965655a01897b6661e30436ddacbc4-node_parede.scn @X      [      ^3Ng0[�h��5��K4    X   res://.godot/exported/133200997/export-fd53652663de6cfaddb6bd4ec7cc3a1a-node_jogador.scn L      �      g�cqV
�k��@#�"9�    ,   res://.godot/global_script_class_cache.cfg   f             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex      �      �Yz=������������    D   res://.godot/imported/luz.png-31ff8aec01abd6668bcbd84ec2be9abb.ctex �"             ��,	���82�j    T   res://.godot/imported/sprite-jogador-v2.png-3bc9a4fc340790cfab4795aa550c846e.ctex   `      �       �����_����)!�    P   res://.godot/imported/sprite-jogador.png-a1c2e352950dae13a4cc93c98c95be33.ctex  �a      |       T�G�׹�˰�-x��5    P   res://.godot/imported/sprite-parede.png-ebdc4136c6f9c444de52f58ba7ed5a7e.ctex   �b      z       ���*�˄b���+Z;       res://.godot/uid_cache.bin  �i      +      �5��$H�*{mdBs        res://Jogador.gd�            |�l݌Q���\��6.       res://Parede.gd �_      h       �����߶k.0�Y�    �   res://godot-coi-serviceworker-962b1abaf14ac62079b9e5321ef98e6f2b09c96e/godot-coi-serviceworker-962b1abaf14ac62079b9e5321ef98e6f2b09c96e/addons/coi_serviceworker/coi_export_plugin.gd           �      �����.o���d`][�E    �   res://godot-coi-serviceworker-962b1abaf14ac62079b9e5321ef98e6f2b09c96e/godot-coi-serviceworker-962b1abaf14ac62079b9e5321ef98e6f2b09c96e/addons/coi_serviceworker/coi_plugin.gd  �      a      k`f�w�OvPN����<%       res://icon.svg   f      �      C��=U���^Qu��U3       res://icon.svg.import   �      �       Ǟ��̣�,�ũ1����       res://luz.png.import�=      �       ��#�u�1�l�L��       res://mundo.tscn.remap  @d      b       �5���-�Di��O��i        res://node_jogador.tscn.remap   �d      i       �j�X���Č̬��,        res://node_obstaculo.tscn.remap  e      k       
��W���f��G���       res://node_parede.tscn.remap�e      h       צ��<�1q����6�       res://project.binaryk            �� ��[�ZJ2� ���    $   res://sprite-jogador-v2.png.import  �`      �       �GTH�o��j!u�`        res://sprite-jogador.png.import  b      �       w�Z������?�ᵮ        res://sprite-parede.png.import  pc      �       >�@w
�H��ׅ�0|    �1�C�{�@tool
extends EditorExportPlugin

const JS_FILE = "coi-serviceworker.min.js"

var plugin_path: String = get_script().resource_path.get_base_dir()
var exporting_web := false
var export_path := ""
var update_export_options := true

func _get_name() -> String:
	return "CoiServiceWorker"

func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	return [
		{
			"option": {
				"name": "include_coi_service_worker",
				"type": TYPE_BOOL
			},
			"default_value": true
		},
		{
			"option": {
				"name": "iframe_breakout",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Disabled,Same Tab,New Tab,New Window"
			},
			"default_value": "Disabled"
		}
	]

func _should_update_export_options(platform: EditorExportPlatform) -> bool:
	if not platform is EditorExportPlatformWeb: return false
	var u = update_export_options
	update_export_options = false
	return u

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	if features.has("web"):
		if not has_method("get_option") or get_option("include_coi_service_worker"):
			exporting_web = true
		export_path = path
		if has_method("get_option") and get_option("iframe_breakout") != "Disabled":
			if export_path.ends_with("index.html"):
				push_error("ERROR: cannot export as index.html with generate_index_popout option set")
			else:
				var html = POPOUT_INDEX_HTML
				var method = get_option("iframe_breakout")
				if method == "Same Tab":
					html = html.replace("__PARAMS__", "target=\"_parent\"")
				elif method == "New Tab":
					html = html.replace("__PARAMS__", "target=\"_blank\"")
				elif method == "New Window":
					var w = ProjectSettings.get_setting("display/window/size/window_width_override")
					if w <= 0:
						w = ProjectSettings.get_setting("display/window/size/viewport_width")
					var h = ProjectSettings.get_setting("display/window/size/window_height_override")
					if h <= 0:
						h = ProjectSettings.get_setting("display/window/size/viewport_height")
					html = html.replace("__PARAMS__", "onclick=\"window.open('__GAME_HTML__', '_blank', 'popup,innerWidth=" + str(w) + ",innerHeight=" + str(h) + "'); return false;\"")
				else:
					push_error("ERROR: invalid iframe breakout method")
				html = html.replace("__GAME_HTML__", export_path.get_file())
				html = html.replace("__TITLE__", ProjectSettings.get_setting("application/config/name"))
				var file = FileAccess.open(export_path.get_base_dir().path_join("index.html"), FileAccess.WRITE)
				file.store_string(html)
				file.close()

func _export_end() -> void:
	if exporting_web:
		var html := FileAccess.get_file_as_string(export_path)
		var pos = html.find("<script src=")
		html = html.insert(pos, "<script>" + EXTRA_SCRIPT + "</script>\n<script src=\"" + JS_FILE + "\"></script>\n")
		var file := FileAccess.open(export_path, FileAccess.WRITE)
		file.store_string(html)
		file.close()
		DirAccess.copy_absolute(plugin_path.path_join(JS_FILE), export_path.get_base_dir().path_join(JS_FILE))
	exporting_web = false

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
	if path.begins_with(plugin_path):
		skip()

const EXTRA_SCRIPT = """
if (!window.SharedArrayBuffer) {
	document.getElementById('status').style.display = 'none';
	setTimeout(() => document.getElementById('status').style.display = '', 1500);
}
"""

const POPOUT_INDEX_HTML = """<doctype html>
<html>
<head>
<title>__TITLE__</title>
<style>
body {
	background-color: black;
}
div {
	margin-top: 40vh;
	text-align: center;
}
a {
	font-size: 18pt;
	color: #eaeaea;
	background-color: #3b3943;
	background-image: linear-gradient(to bottom, #403e48, #35333c);
	padding: 10px 15px;
	cursor: pointer;
	border-radius: 3px;
	text-decoration: none;
}
a:hover {
	background-color: #403e48;
	background-image: linear-gradient(to top, #403e48, #35333c);
}
</style>
</head>
<body>
<div><a href="__GAME_HTML__" __PARAMS__>Play __TITLE__</a></div>
</body>
</html>
"""
p���g�@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin = null

func _enter_tree() -> void:
	var path: String = get_script().resource_path
	export_plugin = load(path.get_base_dir().path_join("coi_export_plugin.gd")).new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null
=�$�A���$�lY�6�GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[  �  �lɮ[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dx3y6mtjcv0io"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 �H����	�o8Uextends CharacterBody2D

const UP = Vector2(0,-1)
const FLAP = 200
const MAXFALLSPEED = 200
const GRAVITY = 10

var Parede = preload("res://node_parede.tscn")
var score = 0

func _ready():
	pass

func _physics_process(delta):
	velocity.y += GRAVITY
	if velocity.y > MAXFALLSPEED:
		velocity.y = MAXFALLSPEED
	
	if Input.is_action_just_pressed("FLAP"):
		velocity.y = -FLAP
	
	var score_label = get_parent().get_parent().get_node("CanvasLayer/Score")
	score_label.text = str(score)
	
	move_and_slide()

func Parede_reset():
	var Parede_instance = Parede.instantiate()
	Parede_instance.position = Vector2(450,randf_range(-45,45))
	get_parent().call_deferred("add_child", Parede_instance)

func _on_resetar_body_entered(body):
	if body.name == "Parede":
		body.queue_free()
		Parede_reset()


func _on_detectar_area_entered(area):
	if area.name == "AreaPontuacao":
		score += 1
	if area.name == "AreaCair":
		get_tree().reload_current_scene()


func _on_detectar_body_entered(body):
	if body.name == "Parede":
		get_tree().reload_current_scene()
�f�n0��z��}GST2            ����                        �  RIFF�  WEBPVP8L�  /��?�iۦ�v�?�q��.�H�$IqB�4ft.���ҶY�_�+Q�d�m���;�ه��>��8�X�A������Nz��l����%l �k�Կ��cx��V�p�Y�k���p��!��GW���Ë���i{�
���e�O����C�_y�%����+c����ْ���]f|���;�����^�2w���v.�q\;��o-��p���H��?@�f��o�����:�d"����U��"�_�_�t�W\�A*���T��n�S�X΄����ᘓD#v.?d�G��e�����8A����=q�9/u��g��Uت^��U��>V���D��րq��V�Y�p��5�FAx�n�I�0��V�A<�#8��9�BӠA�c��G~'�w9�?Z��ݵn$���A�8����e���L1�*�W�3NY��+�3���)��v	�mO<ن�)��N�|a/����<������G9�~��G�l<>P*�q�ڬZ���P���i�וȀ 9�Y���L0,�U��N�)L�ܣ�'������K2C�LS"D$9�צ@ﱇ�ji���BH��;��H�5Ƕ�� o�5��� ��#<}fr(�1k� ���V��)�'�wX��Ck_�3c��{�i`�R������{8�| ���N�� 	���r=)��Ř����̏B�w�t0U�f��|�N-ƀ�I?��� �׻����5O��=�������mr�����#Y�G�:|�8yl ������:{�|;V��G���pY`�f��2)X���b4 �ag�V x��	rg�nf�����!�.}�� �f�G����m�$�����Y]�+,����E����:t���8�2Wh(�0�l�(yP%m�L���� ��-B��{~O4�Y
�W�;��.�u#"c7�CH��g�կdD:���շz�Y?�!dH�g�p��@�{�$�a�hU�߆s���Ƚ��%Gy@�Z��>FẏlFZB�Y8/8F݇� �,�GyhS�]�%�ucEٳ��S,�Z�e<<2>��0��aÚ��S 	��}'/:
Qd��^xD����><����+��*v	Tq&%����#	~�v�<���� �]w:�����k�.�u3��͍�rI;/ ��ֆjM�5f�$ �t�f�����ci�{d	(Rt���b+n5�h�Q���c��/%�$1��Z�膘>B���^3O���6��u���N�*��w�gɝ� ���tdYG1݀�	H)<���A_݌[g�M����YډXHx�N`N4\���L��r���d2�pXd����o�╇sm�*����yv���J�Rx�w�`�2�J���"#��+ݕ2c2[c��햯E�D���Ƀv�2٘�͐�֘ t��4�l1���B �1a0�1�KHł��p毭�N����s�Aja�l�\iE�Eg7�X�Ӕ2˜g��L�D�Z3H��R��ځ����t����"����'d�ό�.�T�e�������٫~v� �}��#l�f�4�J�Q#�%[clؚގ�&��T�< O��Ŝ-���V(�AJi��!��oș�<�3B0K��H+���I,H%�<�`v���߃�ɨD72˨l}�b_ ���o]A�Ģ���Fnu��jJ	>D�DaqX6.�u�0�ʹ3�'~�Drb��멍����g�,��MD0v2��ظMG�T2�)���t��! ��j��!�%�Z���7�.Qn]�DR0�\H���#~� b���ЉߔT�;;���Wq~esF�u��E`Ah�%S�8Ua��c�i�A��g�M�r��c�A�t&	E���&b3���5ҍw�vVA>
�[u����-D�)M��U����0�e�0�4����� �K0�GMN�1s�4� N�9����ϋ}��JLf���L��(�u�ݸ[��f��ϫ!UD�yP$��Y0�_l�F�Jo2ǖ�^VY������ �0@U[#�q!,��i_'�E�M�"Cѯ��c@)�y�+����ܶR�ٲES��{��ߙM�f~G�2
��fD[�<��!�qa��ξ�ιLYE��]�?璮�Q/7H�K�i_ٖl�h߂^6M��eR&��̲�1t�����|%�FÄ/��[�`R�lnȅ/����V�n���=����&ؘ�}�<�<
�*Pv�\!@P��j��
�<UP)q|�`��=�m���n����"@�(�ָk>9�A��@�8�$�C]l�De�84�̒��x��ƏZ!0�W2���%�	��,[��������aOķB�i�.T ��t�g �g7��݅�kz�ga�h���J�y,3*v�0-�P�5A�J�D٠�@��2�.�kv�>شȫˡ��]��c��N�M�(� +	�f���f.��|FY��ƒ��F�0��23`n�	��֌y�1�,@+��U���-���c�/��@#`��b$C���,�Z	 ��� 7��*���9�O9�9[d�/���<� c(ʫ��B� �G�(��ؚ<�g@�����[Mj'�tQ8� 2(����Bڒ�� ��Sx�.��&Y+m�w��J��7��;@�� v�*�Ģ�0<�4
��'�qO���ٲ2ڈ�)0p���Pu5�ͮu���;����Fv�#G��"���k����K���(q��c��||�H�3��)��Y�����.<xO��f���S��S�b�j�(L!�#p��"L�6в_ئ�	P�a��!8�)c-N#��ǦƠ�,8L�4�x�.@"+��I�z���)q�&������ܧ	��t�D�\�w�IQ��R�:�s�m$)/�ɪ= qmi��t��ͣ@%Ҏ޴�4�y%EG���p�/f�A��0i��f�)��(���:�.95��O\O��!�n|UH�E��WTS�i퇍���H�lŊ�ƅv�IFAnPE0�3�p��x�N�P���h4�i�M�2)��h�L��p�e7�K��@����J�+OA�)�2�3N�i֟�s"Pjo�" ��kd��LG�+G"u$��&n�{��5*?��L���8RH��,a
i`j)��{�$��q	��x6�!L��
���GLJW�LĽ��<��3?昇P1��9xH���j�"����E�*����m��*`����"t�EB��i�$�@R��F�gbܮ����%��ox��5�j0Mo/�sI�k�8��Z+,Z_�����Jophz��r��v�I0%�gT��xG`e*>�٦�y$��BF�5-�� �@�L(��< M�W��GX{�Ӎ�����#A��c^HX!��,E��x棂0�ｰ�]�CU��D�V"潯�s^��#��P�F;.��A\(X�,i���_Ë�Jm-��W�z�,����g�Ʒu!Ο5/�n�����_��G�_�?��_��%9��i�W?:��÷��Wu��Z����]�ë�TY��v���k�G�_�402b���w���_��f,��H�_&(G�B��������H��!�Li�|(��Rx�?N���|!B�@	�u#���" �j��A(����p��q�lX%��$��_�&t�#L�ɨ
c���8U|>�����I0Ԓ#c�U��	b�Eh���"<�
��'L�LF�`�>	|��zۿ��L�#"��a���Ȥ4�ex,�A���`�9��CU,>�L񔢱E�*����eBS<���3́rHtAi��@aEA2l�{Im-��:�yB�i�7�b�Ơ\�4
�R����q"��YŚx�C��J�Б��j���:c����qOc+��/8���"I� ��4$� ȔU���2Q��Yρ@�v��kSs��O1�裤D��e��V��_Ù��̟�F�E���1Jt�m����)��FqF�pd?�?c� ��z�Ԋ�1�Ѱ_�0���fK0�� w�����y�ih�_�� Jf��9()�P���(��� �i�l��SL�	6..d�D1Y�Ƌ��f���ִc�q8Ѱ*j��I��`���E�����L�cs�&43��m���#"ey�c��5�53Fd��i�}a�&j�͂� ��(Hd+�!rը_����x�)�C�b�j�(L!�8p
��7Wwp<�$ JWBW��BV��+[���u|1�A:�\�L��ge���%H&o!�l���;�Hd�i�дwH=�I@J0�M�u&�QDܰe7����(J�I&�}�``��<�z�lbAY�R_;Wn�H�S�F=.Y+m�w��
��7��;@�3A��!$��+5M�f�E#��s��<�ӨI�D7�)W�(Q4�9xL�ͨ�����C��S��E��SX���dE���!�K�K}��b�>c�Y�V7U���-��T������B�������ۈ��u����(��˨i��(̅P�b��_��vo$X�J�����E;I���3�.�E��LMg��f!)�tn
�[�AR�73ˌ�$LK(`FM� z�A��u:W��BA��i\�Y���%�[���i�-  �W��@.�B=(Yn��53�K#�,�H���h�`��4�_�T@�h"j7�4R���{f�� n���`�$Z9k>9�A����n�)xTϛ��y"U@v��B�*��j��
�<UP��xe`'�CmtC.|q(�';�:t�-�F �$���\��y�ׯ ���� �ң�����6Ȕ�\�Y6��������v�w�;F�%�qa7\��s����]�?璯�߮E2;/�m߅P)�L-�����bufS��o#�Yn���{����P5K�ǅpC.A��?KkL��E�/��z�R��fOOë5�(lQD�-;��/�y�HZ�Mf��r��ʕ"�ે�d�ž��@7�̌�����
������=f��m��'Ѓ݄42����$c��J9�`'JHc
�Hcq6�1#!�.���l�V�ц�~N����+uS�<F
�Ủ�������kP���o�	W
��`��1Is�mLg~�!X�"Y�`B���@Lc�0f>�7x���,����yXB�[������m)t�7%���N`��^�|gY5YI  ��ų$��RS��yck�,�� w��PC�'f"nMc'c
���t�L%�9�q�kkP�Q��e���?LL1�i�H�S��ς�HN̝ dU�����<-�"I�y�fc!�|�C�0�h꣥#$߷��3m�d����;��rVt��gc0������ ARyB!O�1a�!V����(b��!��������V�iT�D$$�6�1��t�n�V�G����k����� �dzC1$v�I]&�p� ��7�K(AWg�M�c��e�3fc�f�f��\f����o�����	��Y�D"*�U�3U'�5u�瀖�_� �2c:i��<a����ɱ����t�֘ t��,m���dP�S����V���=v0C�i�-0x��S���M*�ժ����ā���N>6� ����] 1�Y �E*Jx�.7��h�`Q��$�i�Ƿ�mF^lB�AyB�B���5��l@��A��Ԣbbv���_����(�C�6y�J��@;�u\� C��c�}�k

��!
h���5�h�Q���c���������;U�C��2 ��X�W̠)����� �k��v��MO��B'3S�;�����"���7�\`a�K�/A��؃@g���q�U{`��B���FBAV�=8�0�.�u�1���� �V큩��х R ��Xz<@O�m�I"���~t2��3��"�a}� ����4�}T�*L�w��6��'���0�ܱ�AT"���lѓͰꦍ�2�*�Ź�ԹGJ0e��py�]ǍV�E�"��
 ���O��za�^;UU�0z�-���~-�2�l����V+,�Yt�{��r�����5��f�0sD��(������:��^Vؓ1QF��J4Ǡ�~-
0���ʥZ���8�O��A?7��=Ț�U�����ޅ<�LG)�gΝ�������{�{^���� 	I=v�kGe@'�`�$V��G^���c�8$u(�s��rB�3y��J��Fj��ĩʑD__
	�T�p(|ډ|�4È_r��w���_^ ���V]g��2�"�5��ЛeKYo4�^oLmꟘ罡�>%O>n�Ej�'z�7��@a���(:��z�gZU�'E
Z���#� ��9�����/��B0.�I�~�
tdߘ��_/6�`��Y�{4��^-��?��ԞN�e��Y���� l��I��'�<(����'��z����e�	
(�D/�a���G����'�?����ySC��8}���k]�pPJ�	쟙��2Jӯ��+��'�;���������v'�;��Sx��[��W�r���ڸB��,��kB�0����������P�Z�*X�-����b��ŮF)�'��2j���^��r���wʁ����Z�/?u��;�蚡�᮸SG ���Dԑ7I8XY俭�١�(ȧ����8��O�{��@����y>���
L����ɿ6?e'��J֯�mV������g�M�5{4t���L�I�~�N�4X����&���vص�,AW;źQ�A�A)�q�0���[�������=_8�����t�h ����^�a�=z�8��crm�����ѩ�]�=i��]|��G� [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://b1shdec068bll"
path="res://.godot/imported/luz.png-31ff8aec01abd6668bcbd84ec2be9abb.ctex"
metadata={
"vram_texture": false
}
 RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://Jogador.gd ��������
   Texture2D    res://sprite-jogador-v2.png ��8E1�\
   Texture2D    res://luz.png W�l<2�:   PackedScene    res://node_parede.tscn �6�Ψ�%
   Texture2D    res://sprite-parede.png #d�i�h�V      local://RectangleShape2D_qamll �         local://RectangleShape2D_uaslg �         local://RectangleShape2D_mmcr4 �         local://RectangleShape2D_ihln1 
         local://PackedScene_sqc35 ;         RectangleShape2D             RectangleShape2D             RectangleShape2D       
     �A  �C         RectangleShape2D       
     �D  B         PackedScene          	         names "   0      Mundo    Node2D    CanvasLayer    follow_viewport_enabled    Score 	   modulate    z_index    clip_contents    offset_left    offset_top    offset_right    offset_bottom    scale -   theme_override_constants/shadow_outline_size +   theme_override_font_sizes/normal_font_size )   theme_override_font_sizes/bold_font_size ,   theme_override_font_sizes/italics_font_size 1   theme_override_font_sizes/bold_italics_font_size )   theme_override_font_sizes/mono_font_size    RichTextLabel    NodeJogador    Jogador    script    CharacterBody2D    CollisionShape2D    shape 	   Sprite2D    texture 	   Detectar    Area2D    Resetar 	   position    PointLight2D    shadow_enabled    texture_scale 	   Camera2D    zoom    NodeParede    NodeParede2    NodeParede3    NodeParede4    NodeParede5 	   AreaCair    _on_detectar_area_entered    area_entered    _on_detectar_body_entered    body_entered    _on_resetar_body_entered    	   variants    $            ��j?��?  �?  �?                  `�     ��     0�     ��
      ?   ?                      
   �zt?�zt?          
   ���<���<         
   ��y?��y?         
     ��                         ��9@
   ��@��@         
     �C    
     �C  ��
     �C    
      D  �A
     D  ��   ���=    ���=  �?   ����
     HC  ��
   f�F@kH�?         
    ��C  �C               node_count             nodes     �   ��������       ����                      ����                           ����                           	      
                     	      
      
      
      
      
                     ����                     ����                          ����                                ����                                ����                     ����                                ����        	             ����                                  ����   !             "                  #   #   ����   $                  ���%                           ���&                           ���'                           ���(                           ���)                                 ����                               !                  *   ����                     ����      "      #             conn_count             conns              ,   +                    .   -              	      .   /                    node_paths              editable_instances              version             RSRC>g3�RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   _bundled       Script    res://Jogador.gd ��������
   Texture2D    res://sprite-jogador-v2.png ��8E1�\      local://RectangleShape2D_qamll �         local://RectangleShape2D_uaslg �         local://PackedScene_els85 �         RectangleShape2D             RectangleShape2D             PackedScene          	         names "         NodeJogador    Node2D    Jogador    script    CharacterBody2D    CollisionShape2D    scale    shape 	   Sprite2D    texture    Detect    Area2D    	   variants                 
   �zt?�zt?          
   ���<���<         
   ��y?��y?               node_count             nodes     8   ��������       ����                      ����                           ����                                ����         	                    
   ����                     ����                         conn_count              conns               node_paths              editable_instances              version             RSRC2�T��RSRC                    PackedScene            ��������                                            	      resource_local_to_scene    resource_name    custom_solver_bias    size    script    closed 
   cull_mode    polygon 	   _bundled       Script    res://Parede.gd ��������
   Texture2D    res://sprite-parede.png #d�i�h�V      local://RectangleShape2D_svh60            local://OccluderPolygon2D_4gqo4 !         local://RectangleShape2D_q2j1h o         local://PackedScene_gn7kn �         RectangleShape2D             OccluderPolygon2D       %        �� @%�  �A @%�  �A  ��  ��  ��         RectangleShape2D             PackedScene          	         names "         NodeParede    Node2D    Parede    script    StaticBody2D    ParedeCimaSprite 	   position    scale    texture 	   Sprite2D    ParedeCimaCol    shape    CollisionShape2D    ParedeCimaOcl 	   occluder    LightOccluder2D    ParedeBaixoSprite    ParedeBaixoCol    ParedeBaixoOcl    AreaPontuacao    Area2D    PontuacaoCol    	   variants                 
        ���
   �Q8=  @?         
   ��?���A          
         HB         
        ��C
         /D
   33s?ףx@               node_count    
         nodes     l   ��������       ����                      ����                     	      ����                                   
   ����                                      ����                          	      ����                                      ����                                      ����      	                          ����                     ����      
                   conn_count              conns               node_paths              editable_instances              version             RSRC�*w>e��RSRC                    PackedScene            ��������                                            	      resource_local_to_scene    resource_name    custom_solver_bias    size    script    closed 
   cull_mode    polygon 	   _bundled       Script    res://Parede.gd ��������
   Texture2D    res://sprite-parede.png #d�i�h�V      local://RectangleShape2D_svh60            local://OccluderPolygon2D_4gqo4 !         local://RectangleShape2D_q2j1h o         local://PackedScene_kx0yl �         RectangleShape2D             OccluderPolygon2D       %        �� �'�  �A �'�  �A  ��  ��  ��         RectangleShape2D       
     �A(~�A         PackedScene          	         names "         NodeParede    Node2D    Parede    script    StaticBody2D    ParedeCimaSprite 	   position    scale    texture 	   Sprite2D    ParedeCimaCol    shape    CollisionShape2D    ParedeCimaOcl 	   occluder    LightOccluder2D    ParedeBaixoSprite    ParedeBaixoCol    ParedeBaixoOcl    AreaPontuacao    Area2D    PontuacaoCol    	   variants                 
        ���
   �Q8=  @?         
   ��?���A          
         HB         
        ��C
         4D
       ��=
   33s?ףx@               node_count    
         nodes     n   ��������       ����                      ����                     	      ����                                   
   ����                                      ����                          	      ����                                      ����                                      ����      	                          ����                     ����      
                         conn_count              conns               node_paths              editable_instances              version             RSRC�k+�extends StaticBody2D

func _ready():
	pass
	
func _physics_process(delta):
	position += Vector2(-2,0)
	
��՝0-2GST2   �  �     ����               ��       �   RIFFz   WEBPVP8Lm   /��� �������IRt���9c�ǎ�ٴm�9i������O��>��W����M&���W��k��D�z��w/�׷:p�2�w�T�^&���������� QA���[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c18qpmknjotph"
path="res://.godot/imported/sprite-jogador-v2.png-3bc9a4fc340790cfab4795aa550c846e.ctex"
metadata={
"vram_texture": false
}
 �GST2            ����                        D   RIFF<   WEBPVP8L/   /� �����������~TQ�e��!��	��cs���A�  C�5`[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dj04hxg2cevcf"
path="res://.godot/imported/sprite-jogador.png-a1c2e352950dae13a4cc93c98c95be33.ctex"
metadata={
"vram_texture": false
}
 ���GST2   �  �     ����               ��       B   RIFF:   WEBPVP8L.   /��� ������ E���"������������������������E���Pa[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cu2mgw5xuyb68"
path="res://.godot/imported/sprite-parede.png-ebdc4136c6f9c444de52f58ba7ed5a7e.ctex"
metadata={
"vram_texture": false
}
 ˲�;��[remap]

path="res://.godot/exported/133200997/export-7007da6367635e832fa0ed2dd817d63f-mundo.scn"
���JU���	4Xh�[remap]

path="res://.godot/exported/133200997/export-fd53652663de6cfaddb6bd4ec7cc3a1a-node_jogador.scn"
^rO@�ɍ[remap]

path="res://.godot/exported/133200997/export-16ab7891c9ae011599b4d7a01161bbe7-node_obstaculo.scn"
��D"[remap]

path="res://.godot/exported/133200997/export-76965655a01897b6661e30436ddacbc4-node_parede.scn"
�C�wd1Elist=Array[Dictionary]([])
5�z{<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
ڿ�r����	   *�(הz   res://icon.svgW�l<2�:   res://luz.pngxo$�ȉ�Q   res://mundo.tscn�Z�s�)   res://node_jogador.tscn$�`����h   res://node_obstaculo.tscn�6�Ψ�%   res://node_parede.tscn��8E1�\   res://sprite-jogador-v2.png�@��¶�l   res://sprite-jogador.png#d�i�h�V   res://sprite-parede.png��v��ECFG      application/config/name         Atraves dos Pilares    application/run/main_scene         res://mundo.tscn   application/config/features$   "         4.1    Forward Plus       application/config/icon         res://icon.svg     editor_plugins/enabled8   "      *   res://addons/coi_serviceworker/plugin.cfg   
   input/FLAP�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode       	   key_label             unicode           echo          script      ��A���!x