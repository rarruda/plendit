class MiscController < ApplicationController

  def frontpage
    @hide_search_field = true

    @popular_topics = [
      {
        title: "Verktøy",
        summary: "Finn verktøy for alle oppgaver rett i nærheten av der du bor.",
        items: [
          {
            title: "Drill",
            link: "link1",
            image: "promo_imgs/drill.jpg"
          },
          {
            title: "Flisekutter",
            link: "link2",
            image: "promo_imgs/flisekutter.jpg"
          },
          {
            title: "Stige",
            link: "link3",
            image: "promo_imgs/stige.jpg"
          }
        ]
      },
      {
        title: "Friluft",
        summary: "Finn telt eller annet friluftsutstyr.",
        items: [
          {
            title: "Lavvo",
            link: "link1",
            image: "promo_imgs/lavvo.jpg"
          },
          {
            title: "Pulk",
            link: "link2",
            image: "promo_imgs/pulk.jpg"
          },
          {
            title: "Telt",
            link: "link3",
            image: "promo_imgs/telt.jpg"
          }
        ]    
      }
    ]
  end

end
