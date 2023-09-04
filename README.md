Bash script to get a sender-receiver pair for specific domains from postfix logs

### Example 

#### Execute 

```Bash
./parse_maillog.sh mail.log 'Aug 18' domain_1.example.com domain_2.example.com
```

#### Output

```Text
71FBFC0F48  Aug  18  08:05:27  johndoe@domain_1.example.com     janedoe@domain_2.example.com
B67E6C0D89  Aug  18  08:12:32  alice@domain_1.example.com       bob@domain_2.example.com
93D53C0D89  Aug  18  09:21:31  eve@domain_1.example.com         dave@domain_2.example.com
```
