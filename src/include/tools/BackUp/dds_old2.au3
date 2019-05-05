
Func LoadDDS()
	Local Const $ToolExistCpt = "dds"
	Local Const $descriptionPattern = "(?i)^Swearware"

	Local Const $reg1 = "(?i)dds.*\.com"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]

		_ArrayAdd($KPRemoveProcessList, $arr1)


EndFunc   ;==>LoadDDS

LoadDDS()
