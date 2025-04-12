use dioxus::prelude::*;

static CSS: Asset = asset!("/assets/main.css");

#[derive(serde::Deserialize)]
struct DogApi {
    message: String,
}

fn main() {
    dioxus::launch(App);
}

#[component]
fn App() -> Element {
    rsx! {
        document::Stylesheet { href: CSS }
        Title {}
        DogView {}
    }
}

#[component]
fn Title() -> Element {
    rsx! {
        div {
            id: "title",
            h1 { "HotDog! 🌭" }
        }
    }
}

fn DogView() -> Element {
    let mut img_src = use_resource(|| async move {
        reqwest::get("https://dog.ceo/api/breeds/image/random")
            .await
            .unwrap()
            .json::<DogApi>()
            .await
            .unwrap()
            .message
    });

    rsx! {
        div {
            id: "dogview",
            img { src: img_src.cloned().unwrap_or_default() }
        }
        div {
            id: "buttons",
            button { onclick: move |_| img_src.restart(), id: "skip", "skip" }
            button { onclick: move |_| img_src.restart(), id: "save", "save!" }
        }
    }
}
