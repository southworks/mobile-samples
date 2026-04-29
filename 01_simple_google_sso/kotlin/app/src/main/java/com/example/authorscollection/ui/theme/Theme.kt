package com.example.authorscollection.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors: ColorScheme = lightColorScheme(
    primary = TealDark,
    onPrimary = SurfaceWhite,
    primaryContainer = TealContainer,
    onPrimaryContainer = TealOnContainer,
    background = AppBackground,
    surface = SurfaceWhite
)

@Composable
fun AuthorsCollectionTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = AppTypography,
        content = content
    )
}

