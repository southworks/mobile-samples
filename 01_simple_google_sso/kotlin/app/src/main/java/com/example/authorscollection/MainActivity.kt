package com.example.authorscollection

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.authorscollection.app.AuthorsCollectionApp
import com.google.firebase.FirebaseApp

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val startupError = resolveFirebaseStartupError()

        setContent {
            AuthorsCollectionApp(startupError = startupError)
        }
    }

    private fun resolveFirebaseStartupError(): String? {
        return if (FirebaseApp.getApps(this).isEmpty()) {
            "Firebase no está inicializado. Agregá app/google-services.json, habilitá Google en Firebase Auth y sincronizá el proyecto."
        } else {
            null
        }
    }
}

