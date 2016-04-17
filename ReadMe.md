# Federated Wiki - Transport Plugin

This plugin, type: transport, creates a drop zone for web content to be
run through a remote web content to wiki page json converter. Its markup
consists of the address of the remote service.

The Transport plugin posts a json document to the remote service with
each drop. The document contains information retrieved from the drop
event's dataTransfer object.

```
{
	"text": getData("text"),
	"html": getData("text/html"),
	"url":  getData("URL")
}
```

The remote service is expected to reply with valid federated wiki page
json. Conventionally this will be decorated with provenance details
when they can be inferred. The returned page will be added to the lineup
but not saved until forked or plundered for content.

## Build

    npm install
    grunt build

## License

MIT

