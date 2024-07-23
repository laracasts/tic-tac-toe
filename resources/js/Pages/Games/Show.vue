<template>
    <AuthenticatedLayout>
        <menu class="grid grid-cols-3 gap-1.5 w-0 min-w-fit mx-auto mt-12">
            <li v-for="(square, index) in boardState" class="bg-gray-300 size-32 grid place-items-center">
                <button @click="fillSquare(index)" v-if="square === 0"
                        class="place-self-stretch bg-gray-200 hover:bg-gray-300 transition-colors"></button>
                <span v-else v-text="square === -1 ? 'X' : 'O'" class="text-4xl font-bold"></span>
            </li>
        </menu>

        <ul class="max-w-sm mx-auto mt-6 space-y-2">
            <li class="flex items-center gap-2">
                <span class="p-1.5 font-bold rounded bg-gray-200">X</span>
                <span>{{ game.player_one.name }}</span>
                <span :class="{ '!bg-green-500': players.find(({id}) => id === game.player_one_id) }" class="bg-red-500 size-2 rounded-full"></span>
            </li>
            <li v-if="game.player_two" class="flex items-center gap-2">
                <span class="p-1.5 font-bold rounded bg-gray-200">O</span>
                <span>Luke</span>
                <span :class="{ '!bg-green-500': players.find(({id}) => id === game.player_two_id) }" class="bg-red-500 size-2 rounded-full"></span>
            </li>
            <li v-else>Waiting for player two…</li>
        </ul>

        <Modal @close="resetGame()" :show="gameState.hasEnded()">
            <div class="p-6">
                <div class="text-6xl font-bold text-center my-12 font-mono uppercase">
                    <span v-if="gameState.current() === gameStates.XWins" class="text-green-600">X has won!</span>
                    <span v-else-if="gameState.current() === gameStates.OWins" class="text-green-600">O has won!</span>
                    <span v-else class="text-orange-600">Stalemate!</span>
                </div>

                <div class="mt-6 flex justify-end">
                    <PrimaryButton @click="resetGame()">Play Again</PrimaryButton>
                </div>
            </div>
        </Modal>
    </AuthenticatedLayout>
</template>

<script setup>
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import {computed, onUnmounted, ref} from "vue";
import Modal from "@/Components/Modal.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import {useGameState, gameStates} from "@/Composables/useGameState.js";
import {router} from "@inertiajs/vue3";

const props = defineProps(['game']);

const boardState = ref([0, 0, 0, 0, 0, 0, 0, 0, 0]);
const gameState = useGameState();
const players = ref([]);

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

    checkForVictory();
};

const checkForVictory = () => {
    const winningLine = lines.map((line) => line.reduce((carry, index) => carry + boardState.value[index], 0))
        .find((sum) => Math.abs(sum) === 3);

    if (winningLine === -3) {
        gameState.change(gameStates.XWins);
        return;
    }

    if (winningLine === 3) {
        gameState.change(gameStates.OWins);
        return;
    }

    if (!boardState.value.includes(0)) {
        gameState.change(gameStates.Stalemate);
    }
};

const resetGame = () => {
    boardState.value = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    gameState.change(gameStates.InProgress);
};

Echo.join(`games.${props.game.id}`)
    .here((users) => players.value = users)
    .joining((user) => router.reload({
        onSuccess: () => players.value.push(user)
    }))
    .leaving((user) => players.value = players.value.filter(({id}) => id !== user.id));

onUnmounted(() => {
    Echo.leave(`games.${props.game.id}`);
});
</script>
