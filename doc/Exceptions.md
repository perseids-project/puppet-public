# Things that aren't fully puppetized

I was unsuccessful in getting the puppet sendmail module to configure the sendmail settings for the AWS SES services properly. This currently needs
to be done manually for any node which which uses sendmail. This is currently just the Monitor node.

The instructions to follow are here:

http://docs.aws.amazon.com/ses/latest/DeveloperGuide/sendmail.html

smtp auth settings are in Hiera, because they are used for SoSOL:

```
sosol::smtp_user
sosol::smtp_password
```

We use the 'email-smtp.us-east-1.amazonaws.com' AWS SES service.
