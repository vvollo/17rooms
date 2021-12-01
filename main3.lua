--$Name:17 комнат$
--$Version: 1.1.1$

require "parser/mp-ru"
require "fmt"
require "autotheme"
-- mp.errhints = false
game.dsc = false

include "verbs"
include "endings"
include "room1"
include "room2"
include "room3"
include "room4"
include "room5"
include "room6"
include "room7"
include "room8"
include "room9"
include "room10"
include "room11"
include "room12"
include "room13"
include "room14"
include "room15"
include "room16"
include "room17"

mp.undo = 20
mp.score = 0 -- enable scoring
mp.maxscore = 60 -- enable scoring
--mp.detailed_inv = true
instead.notitle = false -- enable status
--instead.get_title = 3

mp.autohelp_limit=1
mp.compl_thresh=3
mp.togglehelp=false
mp.autocompl=true
mp.lev_thresh=2

room {
	nam = 'emptyroom';
	title = "Пустая комната";
	dsc = [[Это не ваша комната, её создаст другой автор.]];
	noparser = true;
}

function init()
	pl.word = -"ты/жр,2л"
	pl.room = 'intro_cutscene'
	pl.capacity = 100
	pl.description = function()
		return "Ты умница и красавица в полном расцвете лет, и выглядишь, как и всегда, отлично. А зовут тебя Настя.^" .. dsc_wearing()
	end;
end

function dsc_wearing()
	local found = {}
	me():inventory():for_each(function(v)
		if not v:has('clothing') or not v:has('worn') then
			return
		end
		local _level = v.level or 0;
		if (_level > 0 and _level < 4) then
			table.insert(found, v)
		end
	end)
	local s = "";
	for o = 1, #found do
		if #found > 1 and o == #found then
			s = s .. " и ";
		elseif o > 1 then
			s = s .. ", ";
		end;
		s = s .. found[o]:noun'вн';
	end;
	if #found == 0 then
		s = " костюм Евы. {$fmt em|Это значит, что в игру вкрался баг!}";
	else
		s = s .. ".";
	end;
	return "Ты одета в " .. s;
end;

cutscene {
	nam = 'intro_cutscene';
	text = {
		[[Ты очень любила тётю Агату, и будучи в Петербурге, собиралась её навестить. Однако тётка как сквозь землю провалилась - не отвечала ни на SMS, ни в Ватсапе, а телефон её был вне зоны доступа. Так что, недолго думая, ты решила наведаться в её поместье на окраине города.
		^^Впрочем, стоит рассказать читателю, кто такая тётя Агата, о которой ты так беспокоилась. Овдовев, и унаследовав огромное состояние, эта эксцентричная женщина принялась коллекционировать в своём особняке различные древности, интересные вещи, изобретения, да и просто хлам (по крайней мере по твоему мнению), пытаясь раскрыть не то тайны масонов, не то древних культов, не то тайного мирового правительства... Словом, дома у неё могло найтись что угодно.
		^^]]..fmt.b("17 комнат: Проклятие старого поместья")..fmt.em("^Чтобы узнать подробнее об игре или авторах, введите ИНФО или АВТОРЫ.^Если вы не очень опытный игрок в парсеры, введите СОВЕТЫ.");
	};
	next_to = 'room1_kryltco'
}


Verb {
   "#RedCode",
   "красное море, сказать красное море",
   "RedCode"
}

mp.msg.RedCode = {}
function mp:RedCode()
    if here().nam == 'room11_kabinet' then
	  p(mp.msg.RedCode.RedCodeHint)
    else
          p(mp.msg.RedCode.RedCode)
    end
end
--"может"
mp.msg.RedCode.RedCode = "Ты говоришь \"КРАСНОЕ МОРЕ\". В комнате ничего не произошло. Может нужно сказать эти слова кому-то? Или чему-то?"
mp.msg.RedCode.RedCodeHint = "Ты говоришь \"КРАСНОЕ МОРЕ\". Ничего не происходит, но ты чувствуешь, что на верном пути. Возможно нужно сказать эти слова кому-то или чему-то конкретно в этой комнате?"


Verb {
   "#Xyzzy",
   "xyzzy",
   "Xyzzy"
}

mp.msg.Xyzzy = {}
function mp:Xyzzy()       
  p(mp.msg.Xyzzy.Xyzzy);
end
mp.msg.Xyzzy.Xyzzy = "Ты помнишь, что тётка упоминала это слово, но как она его использовала, ты не знаешь."


Verb {
   "#Score",
   "счёт,счет",
   "Score"
}

mp.msg.Score = {}
function mp:Score()       
  p("Ты набрала "..mp.score.." очков из "..mp.maxscore.." возможных.");
end

Verb {
   "#Authors",
   "автор, авторы",
   "Authors"
}

mp.msg.Authors = {}
function mp:Authors()       
  p( 		"Идея и доработки этой версии игры: vvollo"..[[
		^^Авторы оригинальной игры: Khaelenmore, techniX, Enola, Артур Айвазян, yandexx, Cheshire, gloomy, qwerty, Irremann, Ajenta, Librarian Oak, Zlobot, Антон Ласточкин, blinovvi, ]]..fmt.st("crem")..[[, spline1986, Oreolek, Антон Артамонов, goraph
		^^Тестирование: Khaelenmore, techniX, Enola, Артур Айвазян, yandexx, Cheshire, gloomy, qwerty, Irremann, Ajenta, Librarian Oak, Zlobot, Антон Ласточкин, blinovvi, spline1986, Oreolek, Антон Артамонов, goraph, Гога, Yorodzuyi, Алик Гаджимурадов, vvollo
		^^Спасибо Райану Видеру за то что когда-то он придумал Cragne Manor, technix за то что он подбросил нам идею написать коллективный парсер, Петру Косых за метапарсер и практически ежедневную техническую поддержку участников на протяжении всего этого марафона, spline1986 за прекрасную тему игры, форуму ifiction.ru и отдельно Олегусу, а также дискорд чату ifrus, дискорд и телеграмм каналам INSTEAD, и чату Мануций, Inc. за информационную поддержку.
		^^И отдельное спасибо Горафу за то, что он организовал мероприятие, а также за то, что разрешил (и даже порекомендовал) делать форки оригинальной игры.]]);

end
Verb ({'#Authors', "автор, авторы", "Authors" }, mp.cutscene)

Verb {
   "#Info",
   "инфо, информация, аннотация, предисловие",
   "Info"
}

mp.msg.Info = {}
function mp:Info()       
  p("Изначально планировался только форк игры \"17 комнат\" с косметическими изменениями, но он очень быстро оброс идеями и превратился в... римейк? спин-офф? фанфик? Даже не знаю, как правильно назвать :) В процессе были изменены 14 комнат из 17, добавлены новые подсказки, альтернативные пути решения некоторых паззлов, существенно расширен лор игры и введены три новые концовки, одна из которых счастливая."..[[
		^^Основной идеей оригинальной игры было написание коллективного русскоязычного парсера, где каждый автор писал свою комнату не зная что делают остальные. В связи с этим игроку рекомендуется относится к каждой комнате как к отдельной мини-игре, с несколько отличающимися правилами и соглашениями. Хотя у всей игры в целом есть свой общий метасюжет, который логически завершен и, позволим себе надеяться, непротиворечив.]]);
end
Verb ({'#Info', "инфо, информация, аннотация, предисловие", "Info" }, mp.cutscene)

Verb {
   "#Cry",
   "заплакать, плакать, плачь, заплачь, сесть и заплакать, сесть и плакать, сядь и плачь, сядь и заплачь, обнять и заплакать, обнять и плакать, обними и плачь, обними и заплачь, плакаться, сесть и плакаться, обнять и плакаться, расплакаться, сесть и расплакаться, обнять и расплакаться, поплакаться, сесть и поплакаться, обнять и поплакаться, заплакаться, сесть и заплакаться, обнять и заплакаться",
   "Cry"
}

mp.msg.Cry = {}
function mp:Cry()       
  p("Что, совсем ничего не получается? Ты поплакала. Стало легче?");
end

Verb {
   "#Advice",
   "советы, совет, подсказки, подсказка",
   "Advice"
}

mp.msg.Advice = {}
function mp:Advice()       
  p([[Советы по прохождению:
	^- в игре активно используются глаголы ИГРАТЬ (на чем-то), КРУТИТЬ, ЛОМАТЬ, ПОВЕСИТЬ, ПРИВЯЗАТЬ (СВЯЗАТЬ), РВАТЬ, СЛУШАТЬ/НЮХАТЬ, ТОЛКАТЬ/ТЯНУТЬ;
	^- на предметы мебели можно ПОЛОЖИТЬ или ПОСТАВИТЬ, или даже ВСТАВИТЬ в них что-то, а также самому ВСТАТЬ, СЕСТЬ или ЛЕЧЬ;
	^- команды ОСМОТРЕТЬ, СМОТРЕТЬ ПОД, СМОТРЕТЬ В -- разные, и могут привести к разным результатам (для документов также есть отдельная команда ЧИТАТЬ);
	^- если кажется, что какое-то действие ни к чему не привело, попробуйте осмотреться -- возможно, в комнате что-то изменилось;
	^- иногда под коврами и за картинами что-то спрятано;
	^- не забывайте осматривать стены, пол и потолок в комнатах, даже если они явно не упоминаются;
	^- некоторые паззлы имеют более одного решения, некоторые предметы можно применять несколько раз;
	^- очки начисляются в том числе и за необязательные действия.]]);
end
Verb ({'#Advice', "советы, совет, подсказки, подсказка", "Advice" }, mp.cutscene)
