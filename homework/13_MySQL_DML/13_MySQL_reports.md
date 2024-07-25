# Группировки с ипользованием CASE, HAVING, ROLLUP, GROUPING()
## Для магазина к предыдущему списку продуктов добавить максимальную и минимальную цену и кол-во предложений

```sql
select category, MAX(price) as max_price, MIN(price) as min_price, COUNT(*) as count
from products
group by category;

|category|max_price|min_price|count|
|--------|---------|---------|-----|
|Напитки |3,000    |120      |3    |
|Орехи   |450      |250      |2    |
|Консервы|250      |45       |2    |

```

## Сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории

```sql
select title, category, price,
    MAX(price) OVER (PARTITION BY category)
        AS max_price,
    MIN(price) OVER (PARTITION BY category)
        AS min_price
from products;

|title   |category|price|max_price|min_price|
|--------|--------|-----|---------|---------|
|Килька  |Консервы|45   |250      |45       |
|Оливки  |Консервы|250  |250      |45       |
|Агдам   |Напитки |150  |3,000    |120      |
|Текила  |Напитки |3,000|3,000    |120      |
|Шмурдяк |Напитки |120  |3,000    |120      |
|Арахис  |Орехи   |250  |450      |250      |
|Фисташки|Орехи   |450  |450      |250      |

```

## Сделать rollup с количеством товаров по категориям

```sql
select
  if(GROUPING(category), 'ИТОГО', category) AS category,
  count(*) AS count
from products
group by category with rollup;

|category|count|
|--------|-----|
|Консервы|2    |
|Напитки |3    |
|Орехи   |2    |
|ИТОГО   |7    |

```