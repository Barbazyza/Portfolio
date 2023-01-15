--Посчитайте, сколько компаний закрылось.
SELECT count(status)
FROM company
Where status LIKE '%closed%'

--Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в 
--поле funding_total.
SELECT funding_total 
FROM company
WHERE category_code = 'news'
AND country_code = 'USA'
ORDER BY funding_total  DESC

--Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash' 
AND EXTRACT (YEAR FROM CAST(acquired_at  AS DATE)) IN (2011,2012,2013)

--Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.
SELECT first_name,
last_name,
twitter_username 
FROM people
WHERE twitter_username LIKE 'Silver%'

--Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.
SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
AND last_name LIKE 'K%'

--Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована 
--компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.
SELECT country_code,
SUM(funding_total) AS sum_total
FROM company
GROUP BY country_code
ORDER BY sum_total DESC

--Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
--Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.
SELECT funded_at,
    MIN(raised_amount) AS min_amount,
    MAX(raised_amount) AS max_amount
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0
AND MIN(raised_amount) != MAX(raised_amount)

--Создайте поле с категориями:
--*Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
--*Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
--*Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
--*Отобразите все поля таблицы fund и новое поле с категориями.
SELECT *,
CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN invested_companies< 100 AND  invested_companies>= 20 THEN 'middle_activity'
    WHEN invested_companies < 20 THEN 'low_activity'
    END
FROM fund

--Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых 
--фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.
WITH
cf AS (SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund)

SELECT activity,
ROUND(AVG(investment_rounds),0) as avg_round
FROM cf
GROUP BY activity
ORDER BY avg_round

--Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
--Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год 
--включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. Выгрузите десять самых активных стран-инвесторов.
--Отсортируйте таблицу по среднему количеству компаний от большего к меньшему, а затем по коду страны в лексикографическом порядке.
SELECT country_code,
       MIN(invested_companies) AS min_companies,
       MAX(invested_companies) AS max_companies,
       avg(invested_companies) AS avg_companies
FROM fund
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY avg_companies DESC
LIMIT 10

--Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.
SELECT pl.first_name,
pl.last_name,
ad.instituition 
FROM people AS pl
left JOIN education as ad on pl.id=ad.person_id

--Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. 
-Составьте топ-5 компаний по количеству университетов.
SELECT cm.name AS company,
COUNT(DISTINCT(ed.instituition)) AS count_instituition
FROM company AS cm
inner JOIN people AS pl ON cm.id = pl.company_id
inner JOIN education AS ed ON pl.id = ed.person_id
GROUP BY company
ORDER BY count_instituition DESC
LIMIT 5

--Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.
SELECT co.name
FROM company AS co
inner JOIN funding_round AS fr ON co.id=fr.company_id
WHERE status = 'closed'
AND fr.is_first_round =1
AND fr.is_last_round = 1
GROUP BY co.name

--Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.
WITH
co_cl AS (SELECT co.name,
          co.id
FROM company AS co
inner JOIN funding_round AS fr ON co.id=fr.company_id
WHERE status = 'closed'
AND fr.is_first_round =1
AND fr.is_last_round = 1
GROUP BY co.id)

SELECT pl.id
FROM co_cl
inner JOIN people AS pl ON co_cl.id =  pl.company_id

--Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.
WITH
co_cl AS (SELECT co.name,
          co.id
FROM company AS co
inner JOIN funding_round AS fr ON co.id=fr.company_id
WHERE status = 'closed'
AND fr.is_first_round =1
AND fr.is_last_round = 1
GROUP BY co.id), 

id_pl AS (SELECT pl.id
FROM co_cl
inner JOIN people AS pl ON co_cl.id =  pl.company_id)

SELECT DISTINCT(id_pl.id),
ed.instituition
FROM id_pl
inner JOIN education AS ed ON id_pl.id = ed.person_id

--Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же 
--заведение дважды.
WITH
co_cl AS (SELECT co.name,
          co.id
FROM company AS co
inner JOIN funding_round AS fr ON co.id=fr.company_id
WHERE status = 'closed'
AND fr.is_first_round =1
AND fr.is_last_round = 1
GROUP BY co.id), 

id_pl AS (SELECT pl.id
FROM co_cl
inner JOIN people AS pl ON co_cl.id =  pl.company_id)

SELECT DISTINCT(id_pl.id) AS d_id,
COUNT(ed.instituition)
FROM id_pl
inner JOIN education AS ed ON id_pl.id = ed.person_id
GROUP BY d_id

--Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести 
--только одну запись, группировка здесь не понадобится.
WITH
co_cl AS (SELECT co.name,
          co.id
FROM company AS co
inner JOIN funding_round AS fr ON co.id=fr.company_id
WHERE status = 'closed'
AND fr.is_first_round =1
AND fr.is_last_round = 1
GROUP BY co.id), 

id_pl AS (SELECT pl.id
FROM co_cl
inner JOIN people AS pl ON co_cl.id =  pl.company_id),

pl_inst AS (SELECT DISTINCT(id_pl.id) AS d_id,
COUNT(ed.instituition) AS count_inst
FROM id_pl
inner JOIN education AS ed ON id_pl.id = ed.person_id
GROUP BY d_id)

SELECT AVG(count_inst)
FROM pl_inst

--Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.
*(сервис, запрещённый на территории РФ).
With
pl_id AS (SELECT pl.id
FROM people AS pl
inner JOIN company AS co ON pl.company_id = co.id
WHERE co.name LIKE 'Facebook'),

pl_count_inst AS (SELECT pl_id.id,
COUNT(ed.instituition) AS count_inst
FROM pl_id
inner JOIN education AS ed ON pl_id.id = ed.person_id
GROUP BY pl_id.id)

Select avg(count_inst)
FROM pl_count_inst

--Составьте таблицу из полей:
--*name_of_fund — название фонда;
--*name_of_company — название компании;
--*amount — сумма инвестиций, которую привлекла компания в раунде.
--В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.
SELECT fu.name AS name_of_fund ,
co.name AS name_of_company,
fu_ro.raised_amount AS amount
FROM investment AS inv
inner JOIN company AS co ON inv.company_id = co.id 
inner JOIN fund AS fu ON inv.fund_id = fu.id
inner JOIN funding_round AS fu_ro ON inv.funding_round_id = fu_ro.id
WHERE co.milestones  > 6
AND EXTRACT(YEAR FROM CAST(fu_ro.funded_at AS date)) BETWEEN 2012 AND 2013

--Выгрузите таблицу, в которой будут такие поля:
--*название компании-покупателя;
--*сумма сделки;
--*название компании, которую купили;
--*сумма инвестиций, вложенных в купленную компанию;
--*доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
--Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
--Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью 
--записями.
SELECT co1.name,
       asq.price_amount,
       co2.name,
       co2.funding_total,
       ROUND(asq.price_amount / co2.funding_total)
FROM acquisition AS asq
LEFT JOIN company AS co1 ON asq.acquiring_company_id = co1.id
LEFT JOIN company AS co2 ON asq.acquired_company_id = co2.id
WHERE asq.price_amount != 0
AND co2.funding_total != 0
ORDER BY asq.price_amount DESC, co2.name
LIMIT 10

--Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций 
--не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.
SELECT co.name,
extract(month FROM fr.funded_at) 
FROM company AS co
left JOIN funding_round AS fr ON co.id = fr.company_id
WHERE category_code = 'social'
AND extract(year FROM fr.funded_at) BETWEEN 2010 AND 2013

--Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
--*номер месяца, в котором проходили раунды;
--*количество уникальных названий фондов из США, которые инвестировали в этом месяце;
--*количество компаний, купленных за этот месяц;
--*общая сумма сделок по покупкам в этом месяце.
WITH 
 
f AS (SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS timestamp)) AS month,
      COUNT(DISTINCT(f.name)) AS fund_name_qty
      FROM funding_round AS fr
      LEFT OUTER JOIN investment AS i ON fr.id=i.funding_round_id
      LEFT OUTER JOIN fund AS f ON i.fund_id=f.id
      WHERE EXTRACT(YEAR FROM CAST (fr.funded_at AS timestamp)) BETWEEN 2010 AND 2013
      AND country_code='USA'
      GROUP BY month),
 
a AS (SELECT COUNT(a.acquired_company_id) AS company_qty,
      SUM(a.price_amount) AS price_amount,
      EXTRACT(MONTH FROM CAST(a.acquired_at AS timestamp)) AS month
      FROM acquisition AS a
      WHERE EXTRACT(YEAR FROM CAST (a.acquired_at  AS timestamp)) BETWEEN 2010 AND 2013
      GROUP BY month)
 
SELECT f.month,
       fund_name_qty,
       company_qty,
       price_amount
FROM f LEFT OUTER JOIN a ON f.month=a.month;

--Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год 
--должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.
with
aa AS (SELECT country_code,
       AVG(funding_total) AS avg_funding_2011
FROM company
WHERE EXTRACT(YEAR FROM founded_at) = 2011
      GROUP BY  country_code),
ab AS (SELECT country_code,
       AVG(funding_total) AS avg_funding_2012
FROM company
WHERE EXTRACT(YEAR FROM founded_at) = 2012
      GROUP BY  country_code),
ac AS (SELECT country_code,
       AVG(funding_total) AS avg_funding_2013
FROM company
WHERE EXTRACT(YEAR FROM founded_at) = 2013
      GROUP BY  country_code)

SELECT aa.country_code,
aa.avg_funding_2011,
ab.avg_funding_2012,
ac.avg_funding_2013
FROM aa
JOIN ab ON aa.country_code = ab.country_code
JOIN ac ON ab.country_code = ac.country_code
ORDER BY aa.avg_funding_2011 desc
