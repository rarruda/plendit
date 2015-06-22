# ruby encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Delete all the things!
ActsAsTaggableOn::Tag.delete_all
ActsAsTaggableOn::Tagging.delete_all

Feedback.delete_all
Message.delete_all
Booking.delete_all
AdItem.delete_all
Ad.delete_all
Location.delete_all
User.delete_all

Notification.delete_all




# Set locale to faker:
Faker::Config.locale = 'nb-NO'


### User
# Original demo users:

ad_list = []

#====
u = User.create(
{ "name"=>"Jan Erik Berentsen",
  "phone_number"=>"99994444",
  "ephemeral_answer_percent"=>"25",
  "status"=> "confirmed",
  "email"=>"jan.erik.berentsen+testonly@plendit.com",
  "image_url"=>"https://media.licdn.com/mpr/mpr/shrink_200_200/p/7/005/088/1fe/0cb0e86.jpg",
  "password"=>User.new( :password => Faker::Internet.password(10, 20) ).encrypted_password }
  )
u.confirm!
u.locations.create!({"address_line"=>"Bentsebrugata 23B", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0469"})
u.locations.create!({"address_line"=>"Grensen  5-7", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0159"})
u.locations.create!({"address_line"=>"Støperigata 1", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0250"})

# Ad #1
a = u.ads.create!({"location_id"=>u.locations.first.id, "title"=>"Fjellpulken barnepulk med ski ", "body"=>"Lite brukt Fjellpulken barnepulk leies ut. Pulken er komplett og har veltebøyle, vindskjerm,\r\nryggstøtte, drag og sele med kryssremmer. Overtrekkspose som gir god beskyttelse ved lagring\r\nog transport medfølger. Pulken har alltid vært lagret innendørs. Stoffet er derfor som nytt i farge.\r\nDet er ingen skader på noen deler av pulken.\r\nPå sekstitallet ble konseptet Barnepulken oppfunnet av Egil Rustadstuen, og fikk Merket for god\r\ndesign i 1968. Siden har pulken gjennomgått en stadig utvikling, men med samme grunnkonsept\r\nbasert på et båtformet glassfiberskrog.\r\nFjellpulken er et urnorsk produkt, og nyutviklingen med ski beholder den sterke identiteten. Den\r\nnye pulken er optimalisert for bruk i skiløyper, med bedre ergonomi og sikkerhet for barnet.\r\nFormgivingen er svært appellerende og ergonomien gir friere bruksmuligheter med økt\r\nbevegelighet. Den er mye lettere å gå med. Siden pulken er løftet opp fra bakken blir ikke bare\r\nkomforten for barnet bedre, men det blir også lettere å holde barnet varmt. Tryggheten er\r\nivaretatt med veltebøyle. Detaljene rundt innstillingene er fine, og alt i alt holder produktet en\r\nimponerende kvalitet.", "price"=>"250.0"})
a.tag_list.add( "pulk","fjellpulk","ski" )

a.ad_items.create!()
a.submit_for_review!
a.approve! #(copies to ES)
ad_list << a.id

a.ad_images.create!({"description"=>"Hoved bilde", "image_file_name"=>"sweet-winter-ride.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"183942", "image_updated_at"=>"2015-05-09 21:44:40 UTC", "image_fingerprint"=>"9205ce767ea14d006c228b2f19d5ad78", "weight"=>"1"})
a.ad_images.create!({"description"=>"andre bilde av fjellpulk for barn", "image_file_name"=>"barnepulk_familie.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"275928", "image_updated_at"=>"2015-05-09 21:45:19 UTC", "image_fingerprint"=>"af611969a7f6c9486808ea1d9be9538f", "weight"=>"2"})
a.ad_images.create!({"description"=>"barnapulk på fjell", "image_file_name"=>"barnepulk_paa_fjell.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"206470", "image_updated_at"=>"2015-05-09 21:46:41 UTC", "image_fingerprint"=>"f0394bb930c900a82e374e2563a4a5d0", "weight"=>"3"})

# Ad #2
a = u.ads.create!({"location_id"=>u.locations.second.id, "title"=>"Calix NORDIC LOADER", "body"=>"Calix NORDIC Loader er en helt ny og meget lav takboks fra Calix. Boksen har et flott design og rommer hele 430 liter! Således egner den seg også godt til bagasje utover alpin- og langrennsski. Takboksen(e) er produsert i robust ABS plast som er 100% resirkulerbar. Åpning skjer sideveis fra begge sider og dette gir god tilgang til ski og utstyr.\r\n\r\nTakboksen leies ut med praktiske QuickGrip fester og integrert takbokslys.", "price"=>"270.0"})
#a.tag_list.add( )

a.ad_items.create!()
a.submit_for_review!
a.approve!
ad_list << a.id

a.ad_images.create!({"description"=>"woho!", "image_file_name"=>"kampanjnyhet-takbox-calix-autoform-nordic-loader-svart-hogblank-430-liter.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"46764", "image_updated_at"=>"2015-05-09 21:52:18 UTC", "image_fingerprint"=>"9a940e69b102950febcd26c86cce9674", "weight"=>"1"})
a.ad_images.create!({"description"=>"det er hvor fint den takboks er!", "image_file_name"=>"e5c821231ca66431f423b6cf0832ce18-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"126106", "image_updated_at"=>"2015-05-09 21:53:05 UTC", "image_fingerprint"=>"3e9aa942bee953b0ffde93edb494d389", "weight"=>"2"})
a.ad_images.create!({"description"=>"hvordan det ser ut på en svart bil", "image_file_name"=>"Calix._Tesla.031.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"437034", "image_updated_at"=>"2015-05-09 21:53:39 UTC", "image_fingerprint"=>"bbd34960a276ffa51c6ae2f42fc82cc8", "weight"=>"3"})


#====
u = User.create(
{ "name"=>"Trygve Leite",
  "phone_number"=>"44449999",
  "ephemeral_answer_percent"=>"75",
  "status"=>"confirmed",
  "email"=>"trygve.leite+testonly@plendit.com",
  "password"=>User.new( :password => Faker::Internet.password(10, 20) ).encrypted_password }
  )
u.confirm!
u.locations.create!({"address_line"=>"Kristiansands gate 12 A", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0463"})
u.locations.create!({"address_line"=>"Slottsplassen 1", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0010"})

# Ad #3
a = u.ads.create!({"location_id"=>u.locations.first.id, "title"=>"Skiguard 850 skiboks", "body"=>"Skiguard har designet en lekker, aerodynamisk og lavtliggende ny takboks. Skiguard 830 er\r\nberegnet på mindre biler med kortere tak, blant annet til en rekke mellomstore typer SUV.\r\n\r\nSkiguard er alene om å ha et buet design, for å passe perfekt til de nye takene som er blitt\r\ntrenden de senere år. Skiguard 830 er av samme design og meget buet. Dette gjør at boksen\r\nfår en optimal plassering på de fleste biler.\r\n\r\nDenne boksen er bygget på samme moderne lest som modell 860, er 214 cm lang, og har plass\r\ntil inntil 205 cm lange langrennsski.\r\n\r\nBoksen har også et nyutviklet låssystem som benyttes blant annet i modell 860.", "price"=>"199.0"})
a.tag_list.add( "skiguard", "ski", "takboks" )
a.ad_items.create!()
a.submit_for_review!
a.approve!
ad_list << a.id

a.ad_images.create!({"description"=>"(topp/side) på bil", "image_file_name"=>"923d9086271cceec0e028cbaf552c6d8-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"49609", "image_updated_at"=>"2015-05-10 22:01:08 UTC", "image_fingerprint"=>"8adb3206cecaf56969688d0fa205cf0e", "weight"=>"3"})
a.ad_images.create!({"description"=>"boks", "image_file_name"=>"755010fb57c8810d8561e86093734b67-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"9536", "image_updated_at"=>"2015-05-10 22:00:06 UTC", "image_fingerprint"=>"047d87bb86e198bfd3de5ecf494b5687", "weight"=>"1"})
a.ad_images.create!({"description"=>"boks (side)", "image_file_name"=>"4ea474d60f3fb16e30403c4c0429a841-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"27040", "image_updated_at"=>"2015-05-10 22:00:33 UTC", "image_fingerprint"=>"7337a490bc65a1f5e4adf5b4776e0417", "weight"=>"2"})


# Ad #4
a = u.ads.create!({"location_id"=>u.locations.second.id, "title"=>"Packline F 800 ABS takboks", "body"=>"En nedsenket og praktisk takboks med lav vekt og stor innvendig høyde. Formgitt for å romme det meste på reisen – hele 225 cm lang. Produsert i kraftig miljøvennlig ABS som er 100% resirkulerbar. Vårt nye patenterte hurtigfeste iZi2connect er kjapt og enkelt i bruk. Boksen er utstyrt med vårt patenterte åpningsmekanisme LiftOff som gir inn og utlasting fra 3 sider – samtidig!", "price"=>"249.0"})
a.ad_items.create!()
a.submit_for_review!
a.approve!
ad_list << a.id

a.ad_images.create!({"description"=>"test text", "image_file_name"=>"7f2069f478b782fd2847ee60a8a3e0e6-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"8995", "image_updated_at"=>"2015-05-10 21:58:33 UTC", "image_fingerprint"=>"4a6e50671a45fde469bcf7e5dc95c1ed", "weight"=>"1"})
a.ad_images.create!({"description"=>"på bil (bak)", "image_file_name"=>"ad5f780306570abc67c7475db5564f74-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"149397", "image_updated_at"=>"2015-05-10 21:59:35 UTC", "image_fingerprint"=>"22e61f4002be0d05860857bd06229fe9", "weight"=>"3"})
a.ad_images.create!({"description"=>"på bil", "image_file_name"=>"768bab5e74ccc446c9b7d4353e255874-image.jpeg", "image_content_type"=>"image/jpeg", "image_file_size"=>"108938", "image_updated_at"=>"2015-05-10 21:59:07 UTC", "image_fingerprint"=>"2ba3e2d1fd8b25301c4e86f483b6f137", "weight"=>"2"})


#====
# Batch of synthetic users:
["Fredrik Olsson", "Nina Lund", "Bjarte Dahl", "Kjell Einar Iversen",
 "Åse Jørgensen", "Jon Arne Strand", "Ove Bjerke", "Aina Wold", "Nils Nygaard",
 "Olav Haga", "Eline Nilssen", "Gunnar Sunde"].each_with_index { |name|
  ui = User.create! do |u|
    u.name         = name
    u.phone_number = [ '4', '9' ].sample.to_s + Faker::Base.numerify('#######')
    u.email        = Faker::Internet.safe_email(name).gsub('@', "#{User.count+1}@")
    u.password     = Faker::Internet.password(10, 20)
    u.status       = "confirmed"
  end
}

# A random user will get a location and a ad:
# Ad #5
u = User.all.sample
u.locations.create!({"user_id"=>"41", "address_line"=>"Tennisveien 16 A", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0777"})
a = u.ads.create!({"location_id"=>u.locations.first.id, "title"=>"THULE Dynamic 800 takboks", "body"=>"Sporty, aerodynamisk strømlinjeformet design med spredningsteknologi som optimaliserer måten luften strømmen rundt boksen på, og en taknær bunn som passer perfekt på taket ditt.\u2028\r\n\r\nForhåndsinstallert Power-Click-hurtigmonteringssystem med integrert momentindikator for rask og sikker montering med kun én hånd.\u2028\r\n\r\nDobbeltsidig åpning med utvendige håndtak for praktisk montering, lasting og lossing.\u2028Sentrallåssystem gir maksimal sikkerhet. Den gripevennlige Thule Comfort-nøkkelen kan bare tas ut når alle låsene er lukket. Utformet med en fremoverlent posisjon på biltaket. Gir deg full tilgang til bagasjerommet uten konflikt med  takboksen.\u2028\r\n\r\nIntegrert matte med sklisikker overflate for ekstra sikring av lasten, som i tillegg reduserer støy.", "price"=>"229.0"})
a.ad_items.create!()
a.submit_for_review!
a.approve!
ad_list << a.id

a.ad_images.create!({"description"=>"greie som bruks til å ta ski opp i fjell", "image_file_name"=>"packline_fx_852681p.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"9895", "image_updated_at"=>"2015-05-10 22:01:46 UTC", "image_fingerprint"=>"ad022a5444d4a3daaa20f01c4d41e8c8", "weight"=>"1"})
a.ad_images.create!({"description"=>"takboks", "image_file_name"=>"packline_810_solv.png", "image_content_type"=>"image/png", "image_file_size"=>"352425", "image_updated_at"=>"2015-05-10 22:02:12 UTC", "image_fingerprint"=>"3a44d2c62e47a0b78429862ad7229d2c", "weight"=>"2"})
a.ad_images.create!({"description"=>"takboks i en hummer", "image_file_name"=>"hummer-h2-packline-f-800-abs_full.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"158193", "image_updated_at"=>"2015-05-10 22:02:41 UTC", "image_fingerprint"=>"e6bc67bfd0321b210bf9dc53c61689a1", "weight"=>"3"})

#====
u = User.create(
{ "name"=>"Viking Biking",
  "phone_number"=>"41266496",
  "ephemeral_answer_percent"=>"99",
  "status"=>"confirmed",
  "email"=>"viking.bikes+testonly@plendit.com",
  "image_url"=>"http://graph.facebook.com/viking.biking.tours/picture",
  "password"=>User.new( :password => Faker::Internet.password(10, 20) ).encrypted_password }
  )
u.confirm!
u.locations.create!({"address_line"=>"Nedre Slottsgate 4", "city"=>"Oslo", "state"=>"Oslo", "post_code"=>"0157"})

# Ad #6 / 12
a = u.ads.create!({"location_id"=>u.locations.first.id, "title"=>"Sykkel", "body"=>"18\" Sykkel til utleie. 26\"hjul,21 gir shimano, brukt få ganger. \r\nImponerende kvalitet.\r\nSykkeltype: Terreng", "price"=>"200.0"})
a.tag_list.add( "sykkel", "sommer")
a.submit_for_review!
a.approve!
ad_list << a.id

a.ad_images.create!({"description"=>"Denne type sykkel tilbyr vi", "image_file_name"=>"VB_pic6.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"6161342", "image_updated_at"=>"2015-05-11 18:38:25 UTC", "image_fingerprint"=>"cb3aee8642b001dbb9946b1117cdda23", "weight"=>"1"})
a.ad_images.create!({"description"=>"Det er alle fine sykkler", "image_file_name"=>"VB_pic4.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"5451697", "image_updated_at"=>"2015-05-11 18:39:22 UTC", "image_fingerprint"=>"f32b2fd5221f3c5ff98330b0691754f2", "weight"=>"2"})
a.ad_images.create!({"description"=>"Det er mulig å leie flere sykler av gangen.", "image_file_name"=>"VB_pic12.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"4483465", "image_updated_at"=>"2015-05-11 18:40:32 UTC", "image_fingerprint"=>"6e7d095bd26364d35819dbbf91d22a60", "weight"=>"3"})
a.ad_images.create!({"description"=>"Det er også mulig å bære de syklene.", "image_file_name"=>"VB_pic1.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"2089722", "image_updated_at"=>"2015-05-11 18:42:14 UTC", "image_fingerprint"=>"db7ca8e7f4fa631bb80ac9b90fd48039", "weight"=>"4"})
a.ad_images.create!({"description"=>"anbefales å sykler overalt i byen", "image_file_name"=>"VB_pic3.jpg", "image_content_type"=>"image/jpeg", "image_file_size"=>"893770", "image_updated_at"=>"2015-05-11 18:45:18 UTC", "image_fingerprint"=>"85c18bc2f592ccb7382f2e748f2fec3d", "weight"=>"5"})


## AdImage


## Autogenerated users:
NUM_USERS = 10

NUM_USERS.times do |n|
  User.create! do |u|
    u.name         = Faker::Name.name
    u.phone_number = [4,9].sample.to_s + Faker::Base.numerify('#######')
    u.email        = Faker::Internet.safe_email(u.name).gsub('@', "#{n+1}@")
    u.password     = Faker::Internet.password(10, 20)
    u.status = 2
  end
end

### Ad

#NUM_ADS   = 40
# Load each product from the yaml file
#YAML.load_file(File.expand_path("../seeds/ads.yml", __FILE__)).each do |ad|
#  Ad.create! ad
#end
#
#NB_PRODUCTS = Ad.count

### Feedback
#YAML.load_file(File.expand_path("../seeds/feedbacks.yml", __FILE__)).each do |feedback|
#  Feedback.create! feedback
#end

#User.where("id != ?", ad.user.id ).sample.id
#ad_id = ad_list[i]
def get_from_user_id ad_id
  User.where("id != ?", Ad.find_by( ad_id ).user_id ).sample.id
end

i = 0
ad_id = ad_list[i]
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"En god allround pulk som både jeg og min kone lett kan dra til tross for mye bagasje! Pris,\r\nkvalitet og utleier er det ingenting å utsette på. Anbefales. "})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Jan Erik møtte opp til avtalt tid og produktet stemte godt overens med annonsen. En fantastisk\r\ngod pulk som både minstemann og forelde var veldig fornøyd med og som vi veldig gjerne leier\r\nigjen. Anbefales til alle som ikke har plass hjemme og som samtidig ønsker en pulk av god\r\nkvalitet til en lav pris! "})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"4", "body"=>"Leter du etter en god, lett pulk av god kvalitet, er dette den må du leie. Produktet er helt i tråd\r\nmed annonse-beskrivelsen og til tross for en liten misforståelse fra min side, har jeg ingen\r\nproblem med å anbefale både Jan Erik og pulken til andre. Tommel opp! "})

i += 1
ad_id = ad_list[i]
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"En veldig god skiboks som passet perfekt på bilen vår. Trygve hadde universalfester som vi også\r\nfikk låne uten ekstra kostnad. Fantastisk service og et veldig godt produkt. Anbefales. "})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Vi hadde dessverre ikke mulighet til å hente boksen, men det var ingen problem for utleier. Han\r\ntok den med seg til oss og hjelp til med monteringen. Vi kommer garantert til å leie fra Trygve\r\nigjen! "})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Anbefales da jeg ikke har noe å utsette verken på annonsen eller utleier. "})

i += 1
ad_id = ad_list[i]
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Her var det lite å klage på. Skiboksen satt som smurt på taket og Eivind var behjelpelig med å montere den. Terningkast 5 på både produkt og servicen til Eivind."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"4", "body"=>"Synes det var litt knotete å montere denne boksen. Det ble oppgitt i annonsen at dette skulle være lett som bare det. Men etter ca 30 mi var den på plass og vi kunne sette avgårde mot fjellet. Eivind var uansett super som utleier og hjalp oss både med montering og avmontering."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Både Skiboks og «handelen» med Eivind gikk helt etter planen. Supert opplegg på alle måter!"})

i += 1
ad_id = ad_list[i]
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Hva skal man si annet en at måten Plendit har gjort det enkelt og trygt å leie ting på er fantastisk bra?! Skiboksen var akuratt som det stod i annonsen, Anne var på plass ute i garasjen da vi kom og betalingen gikk raskt og smidig via appen til Plendit. Blir ikke siste gang jeg bruker denne tjenesten."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Både skiboksen og utleier (Anne) fortjener 5 stjerner…super service og kvalitet tvers gjennom på skiboksen."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Ingen ting å utsette. Leier gjerne både skiboks og andre ting av Anne dersom det skulle bli aktuelt senere."})

i += 1
ad_id = ad_list[i]
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Skiboksen var akuratt det vi så etter. Produktet var i sa mme stand som det ble omtalt i på Plendit. Ingen problem med å anbefale Ivar og leie av denne skiboksen til andre."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"4", "body"=>"Boksen var perfekt til den helgen vi skulle til Hemsedal. Veldig lett både å montere og ta av da vi var ferdig med å leie den den av Ivar. Hadde det ikke vært for at Ivar 15 min for sen til avtalt tidspunkt for overlevering så hadde vi gitt han 5 stjerner på ratingen."})
Feedback.create({"ad_id"=>ad_id, "from_user_id"=>get_from_user_id(ad_id), "score"=>"5", "body"=>"Tipp topp...både skiboksen og Ivars service. Anbefales!"})



### AdItem


### Booking

# fixme(RA): Should generate some more random bookings

# Get a random AdItem, and a User who does not own it.
[ User.first.id, User.second.id ].each do |user_id|
  ad = User.find( user_id ).ads.sample
  ad_item_id   = ad.ad_items.all.sample.id
  from_user = User.where("id != ?", ad.user_id ).sample

  b = Booking.create({"ad_item_id"=>ad_item_id, "from_user_id"=>from_user.id, "price"=>ad.price, "booking_from"=>(DateTime.now + 1).iso8601, "booking_to"=>(DateTime.now + 2).iso8601}) ##, "first_reply_at"=>"2015-03-28 11:05:00 UTC"})

  ### Message
  Message.create({"booking_id"=>b.id, "from_user_id"=>from_user.id, "to_user_id"=>ad.user_id, "content"=>"Hei! Lurer på om den tidspunkt passer for deg... Hvis ikke, kan du si ifra?\r\n\r\nMvh,\r\n#{from_user.name}"})
  Message.create({"booking_id"=>b.id , "from_user_id"=>ad.user_id, "to_user_id"=>from_user.id, "content"=>"Den tidspunkt passer helt fint! Da er det bare å komme og hente.\r\n\r\nMvh,\r\n#{ad.user.name}"})
end



# EOF
