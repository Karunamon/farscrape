require 'mechanize' #Heavy lifting
require 'net/http' #Other shenanigans
require 'logger'
#require 'pry' #debugger
require 'rbconfig' #Need to tell what our host OS is

###CONFIGURATION
$certfile = 'cacert.pem'
#Base64 encode these so anybody over your shoulder can't see your login details
$wf_username = Base64.decode64('')
$wf_password = Base64.decode64('')
######

#Real stuff begins here

#Let's set up the scraper.
farscrape = Mechanize.new

# Work around some really silly Windows breakage
# http://blog.emptyway.com/2009/11/03/proper-way-to-detect-windows-platform-in-ruby/
# http://stackoverflow.com/questions/8567973/why-does-accessing-a-ssl-site-with-mechanize-on-windows-fail-but-on-mac-work
farscrape.agent.http.ca_file = File.expand_path($certfile) if RbConfig::CONFIG['host_os'] =~ /mingw|mswin/

#Turn on logging to stdout
farscrape.log = Logger.new(STDOUT)
farscrape.log.level = Logger::WARN

#Look like every other browser out there
farscrape.user_agent_alias = 'Windows IE 8'

#Here we use the "online account access" page. The front page has a login form too,
#but that is much more likely to change in weird ways in the future. This one is
#stable and simple.
farscrape.log.info('Loading signon page')
page = farscrape.get('https://online.wellsfargo.com/signon?LOB=CONS')

#Grab the login form
login_form = page.form('Signon')

#Fill the fields
login_form.userid = $wf_username
login_form.password = $wf_password

farscrape.log.info('Submitting credentials')
page = farscrape.submit(login_form, login_form.buttons.first)

#Now there's an interstitial page. Let's follow that URL!
redirecturl = page.parser.at('meta[http-equiv="Refresh"]')['content'][/URL=(.+)/, 1]
page = farscrape.get(redirecturl)

#At this point we've got a login cookie, so we're golden.
#Occasionally they'll throw some weird advertisement-esque "thing" here.
#Let's make sure we're on the account page!
until page.title.include? 'Account Summary'
    farscrape.log.warn('Could not get account summary. Going to try again.')
    reloadcount +=1
    raise RuntimeError 'Could not get account summary in 3 tries, bailing out!' if reloadcount > 3
    waittime = Random.rand(5..15)
    farscrape.log.warn("Waiting #{waittime} seconds to retry")
    sleep(waittime)
    farscrape.log.warn('Here we go again!')
    page = farscrape.get(redirecturl)
end


accountstable = page.parser.xpath('//table[@id="cash"]//tr') #cash contains the table with our account info. let's get all the TRs

#There will be one tr per account, in addition to the header line and the total line.
#Therefore, we don't care about the first or the last tr's on the page
accountsrows = accountstable[1, accountstable.count-1]

accountresults = []

#Generate an array containing account names and balances.

#This is kind of ugly, but it works. We know the first item in each split row
#will be some name for the account. Depending on how many words there are,
#there may be more, but for sanity's sake, we'll just take the first one.
#Usually the last item in each row will be the available balance, but here
#we can't rely on that due to funny characters (like the (R) symbol) messing
#with the formatting. I can think of no reason someone's account name would
#contain a dollar sign with digits, so we'll use that to know we have an amount.

#tl;dr: HTML be crazy.

accountsrows.each { |row| accountresults.push(row.content.split[0]).push(row.content.split.grep(/\$\d/))}

puts accountresults