## Making of: `most_sold_item_for_merchant(merchant_id)` and `best_item_for_merchant(merchant_id)`

#### This is a blog post
***

First off, we wrote a helper method (`successful_invoice_items`) that took in a merchant id and returned all of the `invoice_items` associated with a successful transaction. We did that by first creating a variable `invoices` that passed the `merchant_id` into the `find_all_by_merchant_id` method for the `invoice_repository`. This left us with an array of all invoices for that particular merchant. We then mapped that array to return the `invoice_id` for each invoice that was stored in the variable `ids`. To find all of the transactions associated with those ids, we `flat_map`ed that array and returned each transaction from the `transaction_repository` that matched with each `id`.  Those were stored into the `transactions` variable. Theeennnnnnn, each transaction was `select`-ed for where the transaction result was a ‘success' and the result was stored into a `successful` variable. Each of those successful transactions was then `map`ed to find the correlating `invoice_id`. And finally, those invoice ids were `map`ed to find the correlating invoice items, and thus the “successful” invoice items.  

For the most sold item in terms of quantity, we first took the successful invoice items  and used the `max_by` method to find that specific merchant’s most selling invoice item. We then checked against the successful invoice items for any other items that might have that same quantity so as not to exclude if there was a tie. Lastly, those invoices were `map`ed to  the `item_repository` to return an array of item instances. Because it’s mapping a variable that could include 1 item or many, the array could have 1 or many elements returned. 

For the best Item for the merchant in terms of price, we again took the `successful_invoice_items` for our specific merchant id and set that equal to an `invoice_ids` variable. We then applied the `max_by` enumerable to that `invoice_ids` variable, and for each item in that variable we multiplied its price by its quantity to find the highest revenue-producing `invoice_id`. We then plugged that into the `find_by_id` method in the `item_repository` in order to return the item instance for the best item.   

In conclusion, writing about code is difficult and we shouldn’t complain about the spec harness. 
