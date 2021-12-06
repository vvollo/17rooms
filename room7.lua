-- Доступное пространство имён для объектов - все имена объектов должны начинаться с "room7_" или "stolovaya_" 
-- Все описания можно менять
-- Задача: Игрок должен найти в локации предмет thooskey.
room {
	nam = "room7_stolovaya";
	title = "Столовая";
	dsc = "К югу кухня, к востоку зал.";
	e_to = 'room10_zal';
	s_to = 'room6_kitchen';
	before_Listen = "Ничего не слышно.";
	before_Smell = "Ничем не пахнет.";
	obj = { 'room7_camel','room7_stand','room7_table','room7_plate','room7_leaf','room7_ribbon','room7_helmet','room7_bird','room7_small_key','room7_shield','room7_plinth','room7_walls','room7_emblem','room7_window','room7_buttons','room7_b1','room7_b2','room7_b3','room7_b4','room7_b5','room7_b6','room7_b7','room7_b8','room7_b9','room7_floor','room7_top' };
}

-- Менять нельзя!!!! Это не ваш предмет!!! Вы не знаете как он выглядит, его придумает другой автор!!!
--obj {
--	-"зубчатый ключ,ключ";
--	nam = "thooskey";
--	description = "Зубчатый ключ.";
--}

obj {
	-"верблюд";
	nam = "room7_camel";
	description = "Механический, умеренно волосатый верблюд, у которого вместо горба полусферическая, серебряная крышка с пупочкой и приводом. Сбоку находится миниатюрная цифровая панель из слоновой кости.";
	before_Take = "Он довольно-таки тяжелый, да и вообще это ни к чему.";
}: attr 'supporter,static,~animate'

obj {
	-"крышка";
	nam = "room7_cap";
	found_in = 'room7_camel';
	description = "Крышка как крышка - ничего интересного. Судя по всему поднимается механическим приводом.";
	before_Take = "Она намертво приварена к приводу.";
	before_Open = "Крышка открывается и закрывается автоматически.";
	before_Close = "Крышка открывается и закрывается автоматически.";
}: attr 'container,static,openable'

obj {
	-"привод";
	nam = "room7_privod";
	found_in = 'room7_camel';
	description = "Посеребренный привод, одна часть которого приварена к крышке, а другая скрывается в волосатых недрах механического верблюда.";
}: attr 'static,concealed'

obj {
	-"цифровая панель,панель";
	nam = "room7_pannel";
	found_in = 'room7_camel';
	description = "Три ряда маленьких кнопок с цифрами от одного до девяти.";
}: attr 'static'

obj {
	-"первая кнопка,кнопка,1";
	default_Event = "Push";
	nam = "room7_b1";
	before_Push = "Сломано. Сколько не нажимай - кнопка не поддается.";
}:attr 'concealed,static'

obj {
	-"вторая кнопка,кнопка,2";
	default_Event = "Push";
	nam = "room7_b2";
	before_Push = "Заело.";
}:attr 'concealed,static'

obj {
	-"третья кнопка,кнопка,3";
	default_Event = "Push";
	nam = "room7_b3";
	before_Push = "Не поддается.";
}:attr 'concealed,static'

obj {
	-"четвертая кнопка,кнопка,4";
	default_Event = "Push";
	nam = "room7_b4";
	before_Push = "Эта кнопка слишком легко нажимается. Видать она уже ничего не делает.";
}:attr 'concealed,static'

obj {
	-"пятая кнопка,кнопка,5";
	default_Event = "Push";
	nam = "room7_b5";
	before_Push = function()
		if _'room7_dish':disabled() then
			p "Что-то зажужжало, завибрировало, щелкнуло, механический верблюд неуклюже заковылял к столу, остановился и крышка со звоном отскочила.";
			enable("room7_dish");
		else
			p "Больше эта кнопка ничего не делает.";
		end;
	end;
}:attr 'concealed,static'

obj {
	-"шестая кнопка,кнопка,6";
	default_Event = "Push";
	nam = "room7_b6";
	before_Push = "Эта кнопка вдавлена внутрь и уже давно ничего не делает.";
}:attr 'concealed,static'

obj {
	-"седьмая кнопка,кнопка,7";
	default_Event = "Push";
	nam = "room7_b7";
	before_Push = "Сломано.";
}:attr 'concealed,static'

obj {
	-"восьмая кнопка,кнопка,8";
	default_Event = "Push";
	nam = "room7_b8";
	before_Push = "Эта кнопка слишком легко нажимается. Видать она уже ничего не делает.";
}:attr 'concealed,static'

obj {
	-"девятая кнопка,кнопка,9";
	default_Event = "Push";
	nam = "room7_b9";
	before_Push = "Заело.";
}:attr 'concealed,static'

obj {
	-"кнопки";
	default_Event = "Push";
	nam = "room7_buttons";
	before_Push = "Ну не все же сразу!";
}:attr 'concealed,static' 

obj {
	-"информационный стенд,стенд";
	nam = "room7_stand";
	description = function()
		walk 'room7_manual';
	end;
}:attr 'static'

cutscene {
	nam = "room7_manual";
	text = {
		"ИНСТРУКЦИЯ ПО ЭКСПЛУАТАЦИИ ОДНОГОРБОГО МЕХАНИЧЕСКОГО ВЕРБЛЮДА С АВТОМАТИЧЕСКОЙ КРЫШКОЙ^^Данное устройство разработано и запатентовано фирмой Кох и Шварц специально для обеспечения безопасности питания, как то предотвращения преднамеренной порчи пищи, отравления оной и других действий направленных на подрывание здоровья владельца дома через третьих лиц. Одногорбый механический верблюд с автоматической крышкой (далее ОМВАК) призван обезопасить и минимизировать цепочку через которую готовое блюдо попадает на стол.";
		"Для введения в эксплуатацию ОМВАК, надлежит... (этот фрагмент руководства утрачен)^^Габаритная модульная мебель фирмы Кох и Шварц размешается согласно пожеланиям заказчика, но... (этот фрагмент руководства утрачен)";
		"Из соображений безопасности возможность открыть автоматическую крышку есть только у двух человек в доме - у повара и у хозяина ОМВАК. Для этого к данной модели прилагаются два разных ключа - явный (для повара) и тайный, о котором никто не должен знать (кроме хозяина). При этом повар может открыть крышку только в том случае, если поднос пуст и проверочная кнопка на его поверхности отжата. Хозяин же может открыть крышку только после его транспортировки до места назначения, но может разблокировать саму возможность открытия крышки для повара.";
		"Запатентованный потайной ключ фирмы Кох и Шварц изготавливается в трех различных исполнениях - запонка, пуговица и брошка. Выбор поставляемой модели потайного ключа для ОМВАК зависит от заказчика и оговаривается заранее.^^Пользоваться потайным ключом крайне просто - стоит поднести его к крышке ОМВАК, как она автоматически откроется. Для окружающих использование вами ключа прикрепленного с этой целью к манжете платья так и останется тайной.";
	};
	next_to = 'room7_stolovaya';
}

obj {
	-"булочка|кайзерка";
	nam = "room7_bun";
	found_in = 'room7_dish';
	description = "Кайзерка с маком - муляж изготовленный из папье-маше. Не очень-то и похожа на настоящую.";
	before_Smell = "Пахнет краской, лаком и растворителем.";
	before_Tear = function(s)
		s:tearApart("разрываешь");
	end;
	before_Attack = function(s)
		s:tearApart("разламываешь");
	end;
	before_Cut = function(s, w)
        	if w == nil then
        		p"Чем ты хочешь разрезать булочку?";
        		return true;
        	end;
        	mp:check_held(w);
        	if w ~= nil then
        		if w ^ "dagger" then
				s:tearApart("разрезаешь");
                		return true;
        		else
                		p"Этим разрезать булочку не получится.";
                		return true;
            		end;
        	end;
        	return false;
    	end;
	tearApart = function(s, t)
		p ("Ты " .. t .. " булочку из папье-маше и обнаруживаешь внутри " .. _'longkey':noun'вн' .. ".");
		move ('longkey',pl);
		mp.score=mp.score+1;
		remove(s);
	end;
	before_Take = "Таскать с собой повсюду муляж булочки? Этого еще не хватало! Пусть лежит где лежит.";
}: attr 'static' : dict {
	["кайзерка/вн"] = "кайзерку";
	["кайзерка/рд"] = "кайзерки";
	["кайзерка/дт"] = "кайзерке";
	["кайзерка/тв"] = "кайзеркой";
	["кайзерка/пр"] = "кайзерке";
}

obj {
	-"стол";
	nam = "room7_table";
	description = "Миниатюрный старинный обеденный столик, но очень тяжелый.";
	['before_Push,Pull,Turn'] = function()
		p "Не стоит даже пытаться - он очень тяжелый и кроме того ты боишься поцарапать пол.";
	end;
	before_Take = "И откуда только такие безумные мысли приходят людям в голову?";
}: attr 'supporter, static'

obj {
	-"пуговица";
	nam = "room7_button";
	found_in = 'room7_table';
	description = "Старинная медная пуговица с чеканным гербом.";
}: attr 'static'

obj {
	-"герб";
	nam = "room7_emblem";
	description = "Щит, на нем изображен шлем, ключик, птица и дубовый лист. По бокам симметрично изогнутые ленты. Ничего особенного.";
}: attr 'scenery'

obj {
	-"шлем";
	nam = "room7_helmet";
}: attr 'scenery'

obj {
	-"щит";
	nam = "room7_shield";
}: attr 'scenery'

obj {
	-"ключик";
	nam = "room7_small_key";
}: attr 'scenery'

obj {
	-"птица";
	nam = "room7_bird";
	description = "Стилизованное изображение птицы.";
}: attr 'scenery,~animate'

obj {
	-"дубовый лист,лист";
	nam = "room7_leaf";
}: attr 'scenery'

obj {
	-"лента|ленты";
	nam = "room7_ribbon";
}: attr 'scenery'

obj {
	-"поднос";
	nam = "room7_dish";
	found_in = 'room7_camel';
}:disable(): attr 'static,supporter'

obj {
	-"пол";
	nam = "room7_floor";
	description = "Шахматный пол. Белые и черные плитки довольно-таки большие. Каждый предмет в комнате стоит на отдельной клетке. По бокам, рядом с плинтусами, нанесены ряды цифр.";
}: attr 'scenery'

obj {
	-"плинтус|плинтусы";
	nam = "room7_plinth";
}: attr 'static,concealed'

obj {
	-"плитка|плитки";
	nam = "room7_plate";
	description = "Белый мрамор, черный мрамор.";
}: attr 'scenery'

obj {
	-"потолок";
	nam = "room7_top";
	description = "Обыкновенный, беленый известью потолок.";
}: attr 'scenery'

obj {
	-"стена|стены";
	nam = "room7_walls";
}: attr 'scenery'

obj {
	-"окно|окна";
	nam = "room7_window";
}: attr 'scenery'
