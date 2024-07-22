<template>
    <AuthenticatedLayout>
        <menu class="grid grid-cols-3 gap-1.5 w-0 min-w-fit mx-auto mt-12">
            <li v-for="(square, index) in boardState" class="bg-gray-300 size-32 grid place-items-center">
                <button @click="fillSquare(index)" v-if="square === 0" class="place-self-stretch bg-gray-200 hover:bg-gray-300 transition-colors"></button>
                <span v-else v-text="square === -1 ? 'X' : 'O'" class="text-4xl font-bold"></span>
            </li>
        </menu>
    </AuthenticatedLayout>
</template>

<script setup>
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import {computed, ref} from "vue";

const boardState = ref([0, 0, 0, 0, 0, 0, 0, 0, 0]);

const xTurn = computed(() => boardState.value.reduce((carry, value) => carry + value, 0) === 0);

const lines = [
    // rows
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    // columns
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    // diagonals
    [0, 4, 8],
    [2, 4, 6],
];

const fillSquare = (index) => {
    boardState.value[index] = xTurn.value ? -1 : 1;

    const winningLine = lines.map((line) => line.reduce((carry, index) => carry + boardState.value[index], 0))
        .find((sum) => Math.abs(sum) === 3);

    if (winningLine === -3) {
        alert("X has won!");
        return;
    }

    if (winningLine === 3) {
        alert("O has won!");
        return;
    }

    if (! boardState.value.includes(0)) {
        alert("Stalemate!");
    }
};
</script>
