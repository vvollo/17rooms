-- Доступное пространство имён для объектов - все имена объектов должны начинаться с "room1_" или "kryltco_" 
-- Все описания можно менять
-- Задача: Игрок должен открыть дверь ключом с именем bigkey и попасть внутрь дома, объект ключа можно создать с любым именем и описанием, после чего он должен пройти на север
-- ВНИМАНИЕ: Это стартовая локация! Не надо делать сложно! Доступ на восток и запад преграждать нельзя!
-- Игрок может придти в локацию как с ключом так и без ключа!

obj {
	-"небольшой ключ,ключ";
	nam = "bigkey";
	description = "Небольшой ключ.";
}

room {
	attack_counter = 0;
	nam = "room1_kryltco";
	title = "Перед домом";
	dsc = function(s)
		if s:once() then
			p [[
			Анастасия повернулась на север и очутилась перед большим особняком. Садовая дорожка уходила на запад и восток. Вокруг особняка густой зеленой стеной возвышался лес. Рядом торчал почтовый ящик. Под ним на земле валялись какие-то обломки.^
			Вся эта картина что-то смутно ей напоминала. Возможно, начало нового приключения?
			]];
			return
		end
		p"Особняк тётушки Агаты, как и положено добропорядочным особнякам, всё так же находится на севере. По садовой дорожке всё так же можно пойти и на запад, и на восток. Почтовый ящик белеет облупившейся краской, отсвечивая на солнце. На земле валяются какие-то обломки.";
	end;
	n_to = 'room1_mansiondoor';
	in_to = 'room1_mansiondoor';
	e_to = 'room2_terassa';  -- <<<<<<<<<< ПУТЬ НА ВОСТОК
	w_to = 'room2_terassa';  -- <<<<<<<<<< ПУТЬ НА ЗАПАД
	s_to = function(s)
		if not isDaemon('room16_AI') then
			p "Ты проделала весь этот путь не для того, чтобы вернуться ни с чем.";
		else
			DaemonStop 'room16_AI';
			walk 'ending_runaway'
		end;
	end;
	before_Listen = "Из леса доносится пение птиц.";
	before_Smell = "Пахнет весной, как обычно это бывает в мае.";
	before_Think = function()
		p("Анастасия попыталась подумать, но безрезультатно. Похоже, думать нужно "..fmt.em("кому-то другому."))
		return true
	end;
	before_Attack = function(s,w)
		if w == _'room16_witch' then
			return false
		end
	    s.attack_counter = s.attack_counter + 1
		pn("Согласно статье 7.17 КоАП РФ, уничтожение или повреждение чужого имущества влечет наложение административного штрафа в размере от трехсот до пятисот рублей.")
		pn("По возвращении в Санкт-Петербург вам будет выписан штраф на сумму " .. (s.attack_counter * 400) .. " рублей.") 
		return true
	end;
	before_Eat = function(s,w)
		p("Анастасия была так голодна, что съела бы и "..w:noun('им')..", но благоразумие взяло вверх, и она решила повременить с трапезой.")
	end;
	obj = {
		'room1_mansion',
		'room1_windows',
		'room1_forest',
		'room1_road',
		'room1_sun',
		'room1_mailbox',
		'room1_shards',
	};
}

door {
	-"дверь,дверца,вход";
	nam = "room1_mansiondoor";
	description = function(s)
		if s:once() then
			p[[
				Дверь в особняк Агаты была сделана в середине 18 века её прадедом, который, как гласила семейная легенда, был дружен с самим Штакеншнейдером. Прадед вырезал ее из модного в то время канадского дуба, придал ей классическую форму и повесил ее на железные петли, которые в свое время, может быть, и были хороши, но ужасно сейчас скрипели. 
				На двери не было никаких орнаментов и узоров, только в левом нижнем углу виднелась одна царапина, о которой говорили, что ее сделал собственной шпорой Александр Иванович Михайловско-Данилевский, наместный мастер Великой масонской ложи Астрея, внучатый племянник деда тётушки Агаты.
			]];
			if s:has'locked' then
				p([[Ну и конечно же, дверь была надежно заперта.]])
			end
			pn("В остальном же дверь была самой обыкновенной, и более подробно описывать её нет никакой надобности.")
			return
		else
			if s:has'locked' then
				pn[[Дверь в особняк заперта.]]
				pn("Как же отпереть дверь? Возможно, нужно немного "..fmt.em("подумать").."?")
			else
				if s:has'open' then
					p[[Дверь в особняк открыта.]]
				else
					p[[Дверь в особняк закрыта, но не заперта.]]
				end
			end
		end
	end;
	after_Unlock = function(s)
		remove('room1_doorkey')
		mp.score=mp.score+1
		return false;
	end;
	with_key = "room1_doorkey";
	door_to = "room3_hall"; -- <<<<<<<<<< СЮДА ВЕДЁТ ДВЕРЬ В ОСОБНЯК, КОГДА ОНА ОТКРЫТА
	found_in = 'room1_kryltco';
}:attr 'openable,lockable,locked,scenery,static'



obj {
	-"дом,домик,особняк,коттедж,строение";
	nam = "room1_mansion";
	description = "Серая громада особняка в стиле северного модерна выделяется на фоне леса. В окнах поблескивает весеннее солнце.";
	before_Enter = function(s, w)
		mp:xaction('Enter', _'room1_mansiondoor')
	end;
}:attr 'scenery'

obj {
	-"лес,деревья";
	nam = "room1_forest";
	description = "Лес вокруг особняка прямо-таки искрился весенней свежестью. Да, весной в лесу очень хорошо, свежий воздух уже не пахнет сыростью, а благоухает ароматами зелени. Начинается новый виток природы. С далекого юга прилетают птицы, их пение наполняет лес веселыми трелями. На ветвях деревьев, в густой зелени появляются новые гнезда. Просыпаются и животные, по своим делам спешат между деревьями ежи и мыши. С ветки на ветку перескакивает проворная белка... извините, увлёкся.";
	before_Take = "Анастасия хотела бы взять с собой весь этот лес вместе с его обитателями, с каждой сойкой и свиристелем, каждой белкой и зайцем, каждым муравейником, прислонившимся к сосенкам посреди грибных полян... простите, автор слегка увлёкся.";
}:attr 'scenery'

obj {
	-"солнце";
	nam = "room1_sun";
	description = "Солнце — ближайшая к Земле звезда. Средняя удалённость Солнца от Земли — 149,6 миллионов километров — приблизительно равна астрономической единице. Сейчас же оно грело так, будто находилось на пару сотен километров поближе.";
}:attr 'scenery'

obj {
	-"окно|окна";
	nam = "room1_windows";
	description = "Сквозь мутные окна особняка виднелись очертания внутренней обстановки, но деталей было не разобрать.";
	before_Take = [[Анастасия подумала: "А не выставить ли окно и проникнуть в дом таким путём?". Но эта смелая и неординарная мысль была отброшена прочь. Дверь, и только дверь, должна была послужить порталом в тётушкин особняк.]];
}:attr 'scenery'

obj {
	-"дорога,дорожка";
	nam = "room1_road";
	description = "Садовая дорожка уходит на запад и возвращается с востока. Или наоборот.";
}:attr 'scenery'

obj {
	-"почтовый ящик,ящик";
	nam = "room1_mailbox";
	capacity = 2;
	description = function(s)
		if s:has'locked' then
			pn("Что-то поблескивает внутри запертого почтового ящика.")
			if s:once() then
			  pn("Надо бы его отпереть. Но как?")
			else
			  pn("Как же отпереть ящик? Возможно, нужно немного "..fmt.em("подумать").."?")
			end
			return true
		else
			if not s:has'open' and _'room1_doorkey':inside(s) then
				pn("В почтовом ящике что-то поблескивает. Нужно поскорее его открыть!")
				return true
			end
		end
		return false
	end;
	before_Take = function(s)
		p "Всесторонне изучив ящик, Анастасия решила, что брать его с собой всё же излишне.";
		return true;
	end,
	after_Unlock = function(s)
		remove('bigkey')
		mp.score=mp.score+1
		return false;
	end;
	with_key="bigkey";
	obj = {
		'room1_doorkey',
		'room1_letter',
	}
}:attr 'scenery,container,openable,lockable,locked'

obj {
	-"обломки ключа,обломки,осколки ключа,осколки";
	nam = "room1_shards";
	description = function(s)
		local txt = "";
		if pl:have("bigkey") then
			txt = "^Ты отмечаешь, что ключ у тебя в кармане ОЧЕНЬ похож на этот.";
		end
		return "Похоже, это когда-то было ключом. Но кто-то разнес его на куски кувалдой или чем потяжелее. Странно." .. txt;
	end;
}:attr 'scenery'

obj {
	-"письмо|записка|конверт";
	nam = "room1_letter";
	description = "Письмо в незапечатанном конверте. В нём сказано: \"Кто бы ты ни был, если читаешь это письмо, ни в коем случае не заходи в дом. Просто уходи, умоляю!\". ^Похоже на почерк тёти Агаты. Что за чёрт?!";
	before_Take = "Письмо тебе без надобности.";
}:attr 'static'

obj {
	-"медный ключ,ключ";
	nam = "room1_doorkey";
	description = "Медный ключ от особняка, слегка позеленевший от старости.";
}
