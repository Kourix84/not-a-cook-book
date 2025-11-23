# Not a Cook book

A modern iOS app that helps you discover, analyze, and manage recipes using AI and image recognition. Snap a photo of your meal, and the app will guess the dish and list its ingredients. Browse, search, and view recipes, or use the AI chat bot for food-related questions.

---

## Features

- 📸 **AI Meal Scanner:** Take a photo of your meal and get dish/ingredient suggestions using OpenAI Vision.
- 🍽️ **Recipe Discovery:** Browse and search a curated list of recipes.
- 🧑‍🍳 **Recipe Details:** View ingredients and step-by-step instructions.
- 🤖 **AI Chat Bot:** Ask food-related questions or analyze meal photos.
- ⚡ **Fast & Modern UI:** Built with SwiftUI and async/await.

---

## Getting Started

### Requirements

- Xcode 18 or later
- iOS 18 SDK or later

### Setup

1. **Clone the repository:**
    ```sh
    git clone https://git.fhict.nl/I539945/not-a-cookbook.git
    cd not-a-cookbook
    ```

2. **Open the project:**
    - Open `Not a Cook book/Not a Cook book.xcodeproj` in Xcode.

3. **API Keys:**
    - The app uses the following APIs:
        - [OpenAI Vision](https://platform.openai.com/docs/guides/vision)
        - [Spoonacular](https://spoonacular.com/food-api)
        - [ImgBB](https://api.imgbb.com/)
    - API keys are already set in the code for demo purposes, but you should replace them with your own for production:
        - `OPENAI_API_KEY` in [`Not-a-Cook-book-Info.plist`](Not%20a%20Cook%20book/Not-a-Cook-book-Info.plist)
        - `apiKey` in [`SpoonacularService.swift`](Not%20a%20Cook%20book/Not%20a%20Cook%20book/Services/SpoonacularService.swift)
        - `apiKey` in [`RecipeSeedService.swift`](Not%20a%20Cook%20book/Not%20a%20Cook%20book/Services/RecipeSeedService.swift)
        - `apiKey` in [`ImgBBUploader.swift`](Not%20a%20Cook%20book/Not%20a%20Cook%20book/Services/ImgBBUploader.swift)

4. **Run the app:**
    - Select the `Not a Cook book` scheme and run on a simulator or device.

---

## Usage

- **Home:** Images of diffrent foods.
- **Recipes:** Search and view recipes.
- **AI:** Chat or analyze meal photos.
- **Settings:** View app info and privacy policy.


---

## Contributing

Pull requests and issues are welcome! Please open an issue to discuss your ideas or report bugs.

---

## License

This project is for educational/demo purposes.

---

## Authors

- Kourosh Esmaeil Tajer